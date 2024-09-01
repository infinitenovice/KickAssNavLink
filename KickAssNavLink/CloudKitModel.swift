//
//  CloudKitModel.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 8/31/24.
//

import CloudKit

class CloudKitModel: ObservableObject {
    static let shared = CloudKitModel()
    
    @Published var destination: CLLocation? = nil
    @Published var destinationString: String = "No Destination"
    @Published var statusMessage: String = "Initializing"
    @Published var errorMessage: String = ""
    @Published var fetchComplete: Bool = false
        
    let container = CKContainer(identifier: "iCloud.InfiniteNovice.KickAssMapLink")
    let RECORD_TYPE = "Destination"
    let LOCATION_FIELD = "Location"
    let TIMESTAMP_FIELD = "Timestamp"
    let DEFAULT_LOCATION = CLLocation(latitude: 0.0, longitude: 0.0)

    init() {
        subscribe()
        fetch()
    }
    
    func subscribe() {
        let subscription = CKQuerySubscription(recordType: RECORD_TYPE, predicate: NSPredicate(value: true), subscriptionID: "KickAssNavLink", options: [.firesOnRecordUpdate, .firesOnRecordCreation])
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "Destination Updated"
        subscription.notificationInfo = notification
        container.publicCloudDatabase.save(subscription) { _, error in
            guard error == nil else {
                self.setErrorMessage(message: "Subscription Error \(String(describing: error?.localizedDescription))")
                return
            }
            self.setStatusMessage(message: "Subscription Successful")
        }
    }
    func fetch() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RECORD_TYPE, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.recordMatchedBlock = { id, result in
            switch result {
            case .success(let record):
                DispatchQueue.main.async{
                    self.destination = record[self.LOCATION_FIELD]
                    self.setDestinationString()
                }
            case .failure(let error):
                self.setErrorMessage(message: error.localizedDescription)
            }
        }
        operation.queryResultBlock = { result in
            switch result {
            case .failure(let error):
                self.setErrorMessage(message: error.localizedDescription)
            default:
                DispatchQueue.main.async{
                    self.fetchComplete = true
                    self.setStatusMessage(message: "Fetch Complete")
                }
            }
        }
        DispatchQueue.main.async{
            self.setStatusMessage(message: "Fetching")
            self.fetchComplete = false
        }
        container.publicCloudDatabase.add(operation)
    }
    
    func save(record: CKRecord) {
        container.publicCloudDatabase.save(record) { _, error in
            guard error == nil else {
                self.setErrorMessage(message: "CloudKit \(error!.localizedDescription)")
                return
            }
            self.setStatusMessage(message: "Record Saved")
        }
    }
    
    func setStatusMessage(message: String) {
        DispatchQueue.main.async {
            self.statusMessage = message
        }
    }
    func setErrorMessage(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
        }
    }
    func setDestinationString() {
        
        func valueToString(value: Double) -> String {
            let formatter: NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 5
                return formatter
            }()
            guard let valueString = formatter.string(from: NSNumber(value: value)) else { return "Error" }
            return valueString
        }
        
        DispatchQueue.main.async {
            let latitude = self.destination?.coordinate.latitude ?? self.DEFAULT_LOCATION.coordinate.latitude
            let longitude = self.destination?.coordinate.longitude ?? self.DEFAULT_LOCATION.coordinate.longitude
            self.destinationString = "\(valueToString(value: latitude)) \(valueToString(value: longitude))"
        }
    }
    
    func mapURL() -> URL {
        let latitude = destination?.coordinate.latitude ?? DEFAULT_LOCATION.coordinate.latitude
        let longitude = destination?.coordinate.longitude ?? DEFAULT_LOCATION.coordinate.longitude
        return URL(string: "maps://?saddr=&daddr=\(latitude),\(longitude)")!
    }
}
