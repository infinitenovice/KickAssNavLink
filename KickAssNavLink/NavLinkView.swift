//
//  NavLinkView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 8/30/24.
//

import SwiftUI

struct NavLinkView: View {
    
    var mapURL = URL(string: "maps://?saddr=&daddr=\(DEFAULT_LOCATION.latitude),\(DEFAULT_LOCATION.longitude)")!
    var body: some View {
        VStack {
            Text("Status: Connected")
            Text(.now, format: .dateTime.day().month().year().hour().minute().second())
            Text(mapURL.absoluteString)
            Button("Test Connection") {

            }   
            .padding()
            .buttonStyle(.borderedProminent)
            Button("Open Map") {
                UIApplication.shared.open(mapURL)
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    NavLinkView()
}
