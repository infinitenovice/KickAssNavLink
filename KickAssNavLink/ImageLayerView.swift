//
//  ImageLayerView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 9/9/24.
//

import SwiftUI

struct ImageLayerView: View {
    @StateObject var navLinkModel = NavLinkModel.shared

    var body: some View {
        VStack {
            Spacer()
            ZStack{
                Image("KickingDonkey")
                    .resizable()
                    .frame(width: 250, height: 250)
                if navLinkModel.transmitting {
                    Image(systemName: "dot.radiowaves.up.forward")
                        .resizable()
                        .frame(width: 75, height: 75)
                        .rotationEffect(Angle(degrees: -15.0))
                        .foregroundColor(.blue)
                        .offset(x:55,y: -120)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    ImageLayerView()
}
