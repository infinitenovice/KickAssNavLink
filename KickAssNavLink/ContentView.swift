//
//  ContentView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 8/24/24.
//

import SwiftUI
import CloudKit

struct ContentView: View {
    @StateObject var cloudKitModel = CloudKitModel.shared
    
    var body: some View {
        VStack {
            Text("\(cloudKitModel.destinationString)")
            Text("\(cloudKitModel.statusMessage)")
            if cloudKitModel.errorMessage != "" {
                Text("Error: \(cloudKitModel.errorMessage)")
            }
            if cloudKitModel.fetchComplete {
                Button("Open Map") {
                    UIApplication.shared.open(cloudKitModel.mapURL())
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
