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
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    AppBackground()
                    
                    switch gameManager.gameState {
                    case .waitingForPlayers:
                        VStack {
                            Text("Waiting For Players...")
                                .font(.title)
                                .foregroundColor(.white)
                            ProgressView()
                        }
                    case .choosingQuestions:
                        DeckSelectionView(gameManager: gameManager)
                    case .playing:
                        GamePage(gameManager: gameManager)
                    case .finished:
                        GameOverView(gm: gameManager)
                    }
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    if gameManager.gameState == .waitingForPlayers {
                        ToolbarItem(placement: .navigationBarLeading) {
                            GoBackButton()
                                .padding(.top, geo.size.width/30)
                                .onTapGesture {
                                    gameManager.match?.disconnect()
                                    gameManager.match = nil
                                    dismiss()
                                }
                        }
                    }
                }
            }
        }
    }
}
