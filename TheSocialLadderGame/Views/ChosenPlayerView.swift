//
//  ChosenPlayerView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 09.02.2025.
//

import SwiftUI

// MARK: Chosen Player
struct ChosenPlayerView: View {
    let playerName: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .foregroundStyle(.yellow)
                .font(.title2)
            
            Text(playerName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.2))
        )
        .padding(.top, 20)
    }
}
