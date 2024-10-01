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
            .frame(width: 40)
            .onTapGesture() {
                navLinkModel.postFoundNotice()
            }
            if let found = navLinkModel.destinationMarker?.status {
                if found {
                    Text("Found")
                } else {
                    Text("Not Found")
                }
            }
            HStack {
                if let latitude = navLinkModel.destinationMarker?.location.coordinate.latitude,
                   let longitude = navLinkModel.destinationMarker?.location.coordinate.longitude {
                    Text(String(format: "%0.5f", latitude))
                    Text(String(format: "%0.5f", longitude))
                }
            }
        }
    }
}

#Preview {
    ClueSiteView()
}
