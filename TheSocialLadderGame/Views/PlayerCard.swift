//
//  PlayerCard.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 09.02.2025.
//

import SwiftUI

// MARK: Player Card
struct PlayerCard: View {
    let playerName: String
    
    var body: some View {
        Text(playerName)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .frame(width: 100, height: 160)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.cardBlue, Color.ultraLightBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LinearGradient(
                        colors: [.ultraLightBlue, .customWhitesmoke],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 1)
            )
    }
}

#Preview {
    PlayerCard(playerName: "Joshua")
        .preferredColorScheme(.dark)
}
