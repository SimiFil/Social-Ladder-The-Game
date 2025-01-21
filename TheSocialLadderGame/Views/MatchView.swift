//
//  MatchView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 17.01.2025.
//

import SwiftUI

struct MatchView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                switch gameManager.gameState {
                case .waitingForPlayers:
                    Text("Waiting For Players...")
                case .choosingQuestions:
                    DeckSelectionView(gameManager: gameManager)
                case .playing:
                    GamePage()
                case .talking:
                    Text("Discussion time...")  // replace with discussion view
                case .finished:
                    VStack {
                        Text("Game Over")
                        Button("Back to Menu") {
                            dismiss()
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Leave") {
                        gameManager.match?.disconnect()
                        dismiss()
                    }
                }
            }
        }
    }
}
