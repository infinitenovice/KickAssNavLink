//
//  ImageLayerView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 9/9/24.
//

import SwiftUI

struct ImageLayerView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("KickingDonkey")
                .resizable()
                .frame(width: 250, height: 250)
            Spacer()
        }
    }
}

#Preview {
    ImageLayerView()
}
