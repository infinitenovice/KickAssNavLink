//
//  ContentView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 8/24/24.
//

import SwiftUI
import CloudKit

struct ContentView: View {
    @StateObject var navLinkModel = NavLinkModel.shared
    
    var body: some View {
        VStack {
            Text("Clue Site")
            ZStack {
                Circle()
                    .stroke(.gray, lineWidth: 2)
                let monogram = navLinkModel.destinationMarker?.monogram ?? "-"
                Text(monogram)
                    .font(.system(size: 26))
            }
            .frame(width: 40)
            if let found = navLinkModel.destinationMarker?.status {
                if found {
                    Text("Found")
                } else {
                    Text("Not Found")
                }
            } else {
                Text("-")
            }
            HStack {
                if let latitude = navLinkModel.destinationMarker?.location.coordinate.latitude,
                   let longitude = navLinkModel.destinationMarker?.location.coordinate.longitude {
                    Text(String(format: "%0.5f", latitude))
                    Text(String(format: "%0.5f", longitude))
                } else {
                    Text("- -")
                }
            }
            Image("KickingDonkey")
                .resizable()
                .frame(width: 250, height: 250)
            Spacer()
            if navLinkModel.destinationMarker != nil {
                Button("Open Map") {
                    if let latitude = navLinkModel.destinationMarker?.location.coordinate.latitude,
                       let longitude = navLinkModel.destinationMarker?.location.coordinate.longitude {
                        if let mapURL = URL(string: "maps://?saddr=&daddr=\(latitude),\(longitude)") {
                            UIApplication.shared.open(mapURL)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                Button("Found") {
                    navLinkModel.siteFound()
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
