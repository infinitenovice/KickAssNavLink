//
//  NavLinkModel.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 9/7/24.
//

import SwiftUI
import CloudKit
import OSLog
import AVFoundation


class NavLinkModel: ObservableObject {
    static let shared = NavLinkModel()
    @Published var destinationMarker: NavLinkMarker?
    @Published var transmitting: Bool = false
    
    let container = CKContainer(identifier: "iCloud.InfiniteNovice.KickAssMapLink")
    var log = Logger(subsystem: "KickAssNavLink", category: "NavLinkModel")
    
    struct NavLinkMarker {
        var monogram:   String
        var location:   CLLocation
        var status:     Bool
    }
    
    struct NavLinkMarkerCK {
        static let type         = "Destination"
        static let timestamp    = "timestamp"
        static let monogram     = "monogram"
        static let location     = "location"
        static let status       = "status"
        
    }
    
    struct FoundNoticeCK {
        static let type         = "FoundNotice"
        static let timestamp    = "timestamp"
        static let monogram     = "monogram"
    }
    
    private init() {
        self.subscribe()
        self.fetchPostedDestination()
    }
    
    func subscribe() {
        let subscription = CKQuerySubscription(recordType: NavLinkMarkerCK.type, predicate: NSPredicate(value: true), subscriptionID: "NavLinkDestinations", options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "Destination Updated"
        subscription.notificationInfo = notification
        container.publicCloudDatabase.save(subscription) { _, error in
            guard error == nil else {
                self.log.error("Subscription Error \(String(describing: error?.localizedDescription))")
                return
            }
            self.log.info("Status Updates Subscription Successful")
        }
    }
    
    func fetchPostedDestination() {
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
                    self.transmitting = false
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
                                    status: status)
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
    func postFoundNotice() {
        if let monogram = destinationMarker?.monogram, let found = destinationMarker?.status {
            if monogram != "?" && found != true {
                self.transmitting = true
                let TRANSMITTING_SOUND = 1004
                AudioServicesPlaySystemSound(SystemSoundID(TRANSMITTING_SOUND))
                let foundNotice = CKRecord(recordType: FoundNoticeCK.type)
                foundNotice[FoundNoticeCK.timestamp] = Date.now
                foundNotice[FoundNoticeCK.monogram] = monogram
                self.container.publicCloudDatabase.save(foundNotice) { _, error in
                    if error == nil {
                        self.log.info("Posted found notice for clue \(monogram)")
                    } else {
                        self.log.error("\(error!.localizedDescription)")
                    }
                }
            } else {
                log.info("Ignored request to post found notice")
                let BUTTON_ERROR_SOUND = 1053
                AudioServicesPlaySystemSound(SystemSoundID(BUTTON_ERROR_SOUND))
            }
        }
    }
}

