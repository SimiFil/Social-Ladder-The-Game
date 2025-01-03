//
//  AppBackground.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 03.01.2025.
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.darkNavy, Color.darkNavy.opacity(0.95)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground()
}
