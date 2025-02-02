//
//  GameOverView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 02.02.2025.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var gm: GameManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Game Over")
            Button {
                gm.gameState = .choosingQuestions
            } label: {
                Text("Play Again")
            }
            Button("Back to Menu") {
                gm.match?.disconnect()
                dismiss()
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    GameOverView(gm: GameManager())
}
