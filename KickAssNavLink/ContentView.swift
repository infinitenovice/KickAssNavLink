//
//  ContentView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 8/24/24.
//

import SwiftUI
import CloudKit

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    var navLinkModel = NavLinkModel.shared

    var body: some View {
        ZStack {
            ImageLayerView()
            InfoLayerView()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                navLinkModel.fetchPostedDestination()
            }
        }
    }
}

#Preview {
    ContentView()
}
