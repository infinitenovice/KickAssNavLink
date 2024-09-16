//
//  ContentView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 8/24/24.
//

import SwiftUI
import CloudKit

struct ContentView: View {
    
    var body: some View {
        ZStack {
            ImageLayerView()
            InfoLayerView()
        }
    }
}

#Preview {
    ContentView()
}
