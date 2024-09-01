//
//  NavLinkViewModel.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 8/30/24.
//

import SwiftUI
import CloudKit
import UserNotifications


class NavLinkViewModel: ObservableObject {
    
    @Published var destination: CLLocation? = nil
    @Published var status: String = ""
    
    let container = CKContainer(identifier: "iCloud.InfiniteNovice.KickAssMapLink")
    var destinationRecord: CKRecord? = nil
    
    
    init() {
        getiCloudStatus()
//        queryActiveDestination()
//        subscribeToNotifications()
    }
    
    private func getiCloudStatus() {
        CKContainer.default().accountStatus { [weak self] returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    self?.status = CloudKitStatus.iCloudSignedIn.rawValue
                    print("iCloud signed in")
                case .couldNotDetermine:
                    self?.status = CloudKitStatus.iCloudAccountNotDetermined.rawValue
                case .restricted:
                    self?.status = CloudKitStatus.iCloudAccountRestricted.rawValue
                case .noAccount:
                    self?.status = CloudKitStatus.iCloudAccountNotFound.rawValue
                case .temporarilyUnavailable:
                    self?.status = CloudKitStatus.iCloudAccountUnavailable.rawValue
                default:
                    self?.status = CloudKitStatus.iCloudAccountUnkown.rawValue
                }
            }
        }
    }
    
    enum CloudKitStatus: String {
        case iCloudSignedIn = "Signed In"
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnavailable
        case iCloudAccountUnkown
    }
    
    func subscribeToNotifications() {
        let subscription = CKQuerySubscription(recordType: DESTINATION_RECORD, predicate: NSPredicate(value: true), subscriptionID: "KickAssNavLink", options: [.firesOnRecordUpdate, .firesOnRecordCreation])
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "Destination Updated"
        notification.desiredKeys = [LOCATION_FIELD]
        subscription.notificationInfo = notification
        container.publicCloudDatabase.save(subscription) { _, error in
            guard error == nil else {
                print("Subscription Error")
                return
            }
            print("Subscription saved")
        }
    }
    
    func queryActiveDestination() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: DESTINATION_RECORD, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordMatchedBlock = { id, result in
            switch result {
            case .success(let record):
                DispatchQueue.main.async{
                    self.destinationRecord = record
                    self.destination = record[LOCATION_FIELD]!
                    print("Destination set")
                }
            case .failure(let error):
                print(error)
            }
        }
        operation.queryResultBlock = { result in
            switch result {
//            case .success(let cursor):
//                print("query successful")
//                if let cursor = cursor {
//                    // do nothing
//                }
            case .failure(let error):
                print(error)
            default:
                print("query successful")
            }
        }
        container.publicCloudDatabase.add(operation)
    }
    
    func saveRecord(record: CKRecord) {
        container.publicCloudDatabase.save(record) { _, error in
            guard error == nil else {
                print("CloudKit Save Error: \(error!.localizedDescription)")
                return
            }
            print("Record saved")
        }
    }
    
    func newRecord() {
        let record = CKRecord(recordType: DESTINATION_RECORD)
        record[LOCATION_FIELD] = DEFAULT_LOCATION
        record[SEQUENCE_FIELD] = 0
        saveRecord(record: record)
    }
    
    func updateSequenceNumber() {
        if let record = destinationRecord {
            record[SEQUENCE_FIELD] = record[SEQUENCE_FIELD]! + 1
            saveRecord(record: record)
        } else {
            print("No destination record to update")
        }
    }
    
    func testConnection() {
        if status == CloudKitStatus.iCloudSignedIn.rawValue {
            print("Testing Connection")
            if destinationRecord == nil {
                print("Failed - no destination record")
            } else {
                destination = nil
                container.publicCloudDatabase.save(destinationRecord!) { _, error in
                    guard error == nil else {
                        print("CloudKit Save Error")
                        return
                    }
                    print("Save successful")
                }
            }
        }
    }
    
    func destinationString() -> String {
        if let destination = self.destination {
            var coordString = String(destination.coordinate.latitude)
            coordString += " "
            coordString += String(destination.coordinate.longitude)
            return coordString
        } else {
            return "No Destination Found"
        }
    }
    
    func mapURL() -> URL {
        //    @Published var mapURL = URL(string: "maps://?saddr=&daddr=\(DEFAULT_LOCATION.latitude),\(DEFAULT_LOCATION.longitude)")!
        let latitude = destination?.coordinate.latitude ?? DEFAULT_LOCATION.coordinate.latitude
        let longitude = destination?.coordinate.longitude ?? DEFAULT_LOCATION.coordinate.longitude
        return URL(string: "maps://?saddr=&daddr=\(latitude),\(longitude)")!
    }
}
