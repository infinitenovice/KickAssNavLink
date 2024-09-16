//
//  NavLinkModel.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 9/7/24.
//

import SwiftUI
import CloudKit
import OSLog


class NavLinkModel: ObservableObject {
    static let shared = NavLinkModel()
    var log = Logger(subsystem: "KickAssNavLink", category: "NavLinkModel")
    
    @Published var destinationMarker: NavLinkMarker?
    
    let container = CKContainer(identifier: "iCloud.InfiniteNovice.KickAssMapLink")
    struct NavLinkMarker {
        var monogram:   String
        var location:   CLLocation
        var status:     Bool
        var record:     CKRecord
    }
    struct NavLinkMarkerCK {
        // Header
        static let type         = "Destination"
        static let timestamp    = "timestamp"
        // Payload
        static let monogram     = "monogram"
        static let location     = "location"
        static let status       = "status"
        
    }
    private init() {
        self.subscribe()
        self.fetchPosted()
    }
    func subscribe() {
        let subscription = CKQuerySubscription(recordType: NavLinkMarkerCK.type, predicate: NSPredicate(value: true), subscriptionID: "KickAssNavLink", options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "Site Updated"
        subscription.notificationInfo = notification
        container.publicCloudDatabase.save(subscription) { _, error in
            guard error == nil else {
                self.log.error("Subscription Error \(String(describing: error?.localizedDescription))")
                return
            }
            self.log.info("Status Updates Subscription Successful")
        }
    }
    func fetchPosted() {
        var records: [CKRecord] = []
        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: NavLinkMarkerCK.timestamp, ascending: false)
        let query = CKQuery(recordType: NavLinkMarkerCK.type, predicate: predicate)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        operation.recordMatchedBlock = { id, result in
            switch result {
            case .success(let record):
                records.append(record)
                self.log.info("Record fetched: \(record.recordID.recordName)")
            case .failure(let error):
                self.log.error("\(error.localizedDescription)")
            }
        }
        operation.queryResultBlock = { result in
            switch result {
            case .success(_ ):
                DispatchQueue.main.async {
                    if records.isEmpty {
                        self.destinationMarker = nil
                        self.log.info("No sites published")
                    } else {
                        if records.count > 1 {
                            self.log.error("Multiple sites published: \(records.count)")
                        }
                        let record = records[0]
                        if let location = record[NavLinkMarkerCK.location] as? CLLocation,
                           let monogram = record[NavLinkMarkerCK.monogram] as? String,
                           let status = record[NavLinkMarkerCK.status] as? Bool {
                            if monogram == "nil" {
                                self.destinationMarker = nil
                            } else {
                                self.destinationMarker = NavLinkMarker(
                                    monogram: monogram,
                                    location: location,
                                    status: status,
                                    record: record)                                
                            }
                            self.log.info("Site fetched")
                        } else {
                            self.log.error("CKRecord Content Invalid")
                        }
                    }
                }
                
            case .failure(let error):
                self.log.error("\(error.localizedDescription)")
            }
        }
        self.container.publicCloudDatabase.add(operation)
        
    }
    func postSiteUpdate() {
        if let updatedPost = destinationMarker?.record {
            self.container.publicCloudDatabase.fetch(withRecordID: updatedPost.recordID) { record, error in
                guard error == nil else {
                    self.log.error("\(error!.localizedDescription)")
                    return
                }
                if let record = record {
                    record[NavLinkMarkerCK.timestamp] = Date.now
                    record[NavLinkMarkerCK.status] = true  //Mark as found
                    self.container.publicCloudDatabase.save(record) { _, error in
                        guard error == nil else {
                            self.log.error("\(error!.localizedDescription)")
                            return
                        }
                        self.container.publicCloudDatabase.fetch(withRecordID: record.recordID) { _, error in
                            guard error == nil else {
                                self.log.error("\(error!.localizedDescription)")
                                return
                            }
                            DispatchQueue.main.async {
                                self.log.info("Site Updated - requesting to mark as found \(record.recordID.recordName)")
                                self.destinationMarker = nil
                            }
                        }
                    }
                }
            }
        }
    }
}

