//
//  ClueSiteView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 9/9/24.
//

import SwiftUI

struct ClueSiteView: View {
    @StateObject var navLinkModel = NavLinkModel.shared

    var body: some View {
        VStack {
            Text("Clue Site")
            ZStack {
                Circle()
                    .stroke(.gray, lineWidth: 2)
                let monogram = navLinkModel.destinationMarker?.monogram ?? "-"
                Text(monogram)
                    .font(.system(size: monogram.count > 1 ? 20 : 26))
            }
            .onTapGesture() {
                if let found = navLinkModel.destinationMarker?.status {
                    if !found {
                        navLinkModel.postSiteUpdate()
                    }
                }
            }
            .frame(width: 40)
            if let found = navLinkModel.destinationMarker?.status {
                if found {
                    Text("Found")
                } else {
                    Text("Not Found")
                }
            } else {
                Text("Hey Jackass,")
                    .italic()
            }
            HStack {
                if let latitude = navLinkModel.destinationMarker?.location.coordinate.latitude,
                   let longitude = navLinkModel.destinationMarker?.location.coordinate.longitude {
                    Text(String(format: "%0.5f", latitude))
                    Text(String(format: "%0.5f", longitude))
                } else {
                    Text("Gimme a clue!")
                        .italic()
                }
            }
        }
    }
}

#Preview {
    ClueSiteView()
}
