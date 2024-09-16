//
//  InfoLayerView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 9/9/24.
//

import SwiftUI

struct InfoLayerView: View {
    @StateObject var navLinkModel = NavLinkModel.shared

    var body: some View {
        VStack {
            if !navLinkModel.transmitting {
                if navLinkModel.destinationMarker != nil {
                    ClueSiteView()
                        .frame(maxHeight: 125)
                        .padding(.top)
                    Spacer()
                    OpenMapButtonView()
                        .padding(.bottom, 60)
                } else {
                    GimmeAClueView()
                        .padding(.top, 60)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    InfoLayerView()
}
