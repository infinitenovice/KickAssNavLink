//
//  OpenMapButtonView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 9/9/24.
//

import SwiftUI

struct OpenMapButtonView: View {
    @StateObject var navLinkModel = NavLinkModel.shared
    
    var body: some View {
        VStack {
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
            }
        }
    }
}

#Preview {
    OpenMapButtonView()
}
