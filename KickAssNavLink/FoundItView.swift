//
//  FoundItView.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 9/17/24.
//

import SwiftUI

struct FoundItView: View {
    var body: some View {
        HStack{
            Image(systemName: "wave.3.left")
            Text("Found It!")
                .padding()
            Image(systemName: "wave.3.right")
        }
        .font(.system(size: 16, weight: .bold))
    }
}

#Preview {
    FoundItView()
}
