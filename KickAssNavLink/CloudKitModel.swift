//
//  CloudKitModel.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 8/31/24.
//

//import CloudKit
//
//class CloudKitModel: ObservableObject {
//    static let shared = CloudKitModel()
//    
//    @Published var destination: CLLocation? = nil
//    @Published var destinationString: String = "No Destination"
//    @Published var statusMessage: String = "Initializing"
//    @Published var errorMessage: String = ""
//    @Published var fetchComplete: Bool = false
//    @Published var monogram: String = "-"
//    @Published var siteStatus: String = ""
//    
//    var destinationRecord: CKRecord? = nil
//    var destinationFound: Bool = false
//        
//    let container = CKContainer(identifier: "iCloud.InfiniteNovice.KickAssMapLink")
//    let RECORD_TYPE = "Destination"
//    let LOCATION_FIELD = "Location"
//    let TIMESTAMP_FIELD = "Timestamp"
//    let FOUND_FIELD = "Found"
//    let MONOGRAM_FIELD = "Monogram"
//    let DEFAULT_LOCATION = CLLocation(latitude: 0.0, longitude: 0.0)
//
//    init() {
//        subscribe()
//        fetch()
//    }
//    
//    func subscribe() {
//        let subscription = CKQuerySubscription(recordType: RECORD_TYPE, predicate: NSPredicate(value: true), subscriptionID: "KickAssNavLink", options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
//        let notification = CKSubscription.NotificationInfo()
//        notification.alertBody = "Destination Updated"
//        subscription.notificationInfo = notification
//        container.publicCloudDatabase.save(subscription) { _, error in
//            guard error == nil else {
//                self.setErrorMessage(message: "Subscription Error \(String(describing: error?.localizedDescription))")
//                return
//            }
//            self.setStatusMessage(message: "Subscription Successful")
//        }
//    }
//    func fetch() {
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: RECORD_TYPE, predicate: predicate)
//        let operation = CKQueryOperation(query: query)
//        operation.recordMatchedBlock = { id, result in
//            switch result {
//            case .success(let record):
//                DispatchQueue.main.async{
//                    self.destinationRecord = record 
//                    self.monogram = record[self.MONOGRAM_FIELD] as! String
//                    self.destination = record[self.LOCATION_FIELD]
//                    self.destinationFound = record[self.FOUND_FIELD] as! Bool
//                    if self.destinationFound {
//                        self.siteStatus = "Found"
//                    } else {
//                        self.siteStatus = "Not Found"
//                    }
//                    self.setDestinationString()
//                    print("Matchedblock success")
//                }
//            case .failure(let error):
//                self.setErrorMessage(message: error.localizedDescription)
//            }
//        }
//        operation.queryResultBlock = { result in
//            switch result {
//            case .failure(let error):
//                self.setErrorMessage(message: error.localizedDescription)
//            default:
//                DispatchQueue.main.async{
//                    self.fetchComplete = true
//                    self.setStatusMessage(message: "Fetch Complete")
//                }
//            }
//        }
//    
//        self.setStatusMessage(message: "Fetching")
//        self.monogram = "-"
//        self.siteStatus = "-"
//        self.destinationString = "-"
//        self.fetchComplete = false
//        container.publicCloudDatabase.add(operation)
//    }
//    
//    func save(record: CKRecord) {
//        container.publicCloudDatabase.save(record) { _, error in
//            guard error == nil else {
//                self.setErrorMessage(message: "CloudKit \(error!.localizedDescription)")
//                return
//            }
//            self.setStatusMessage(message: "Record Saved")
//        }
//    }
//    func siteFound() {
//        DispatchQueue.main.async {
//            self.destinationRecord![self.FOUND_FIELD] = true
//            self.save(record: self.destinationRecord!)
//            self.fetch()
//        }
//    }
//    func setStatusMessage(message: String) {
//        DispatchQueue.main.async {
//            self.statusMessage = message
//            print(message)
//
//        }
//    }
//    func setErrorMessage(message: String) {
//        DispatchQueue.main.async {
//            self.errorMessage = message
//            print(message)
//        }
//    }
//    func setDestinationString() {
//        
//        func valueToString(value: Double) -> String {
//            let formatter: NumberFormatter = {
//                let formatter = NumberFormatter()
//                formatter.numberStyle = .decimal
//                formatter.minimumFractionDigits = 5
//                return formatter
//            }()
//            guard let valueString = formatter.string(from: NSNumber(value: value)) else { return "Error" }
//            return valueString
//        }
//        
//        DispatchQueue.main.async {
//            let latitude = self.destination?.coordinate.latitude ?? self.DEFAULT_LOCATION.coordinate.latitude
//            let longitude = self.destination?.coordinate.longitude ?? self.DEFAULT_LOCATION.coordinate.longitude
//            self.destinationString = "\(valueToString(value: latitude)) \(valueToString(value: longitude))"
//        }
//    }
//    
//    func mapURL() -> URL {
//        let latitude = destination?.coordinate.latitude ?? DEFAULT_LOCATION.coordinate.latitude
//        let longitude = destination?.coordinate.longitude ?? DEFAULT_LOCATION.coordinate.longitude
//        return URL(string: "maps://?saddr=&daddr=\(latitude),\(longitude)")!
//    }
//}
