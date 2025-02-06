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
    @State var matchWinner: String
    
    init(gm: GameManager) {
        self.gm = gm
        matchWinner = gm.getSortedScores().first?.key ?? "Unknown"
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppBackground()
                
                VStack(spacing: 30) {
                    if gm.players.count < gm.minPlayers {
                        Text("Not enough players to continue.\nPlease return the main menu.")
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    } else {
                        Text("Game Over")
                            .textCase(.uppercase)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        VStack(spacing: 15) {
                            Text("The winner is:")
                                .font(.title2)
                                .foregroundStyle(.white)
                            
                            Text(matchWinner)
                                .font(.system(size: 40, weight: .heavy))
                                .foregroundStyle(.yellow)
                        }
                        
                        VStack(spacing: 20) {
                            if gm.isHost {
                                Button {
                                    gm.gameState = .choosingQuestions
                                } label: {
                                    Text("Play Again")
                                        .font(.headline)
                                        .frame(width: geo.size.width * 0.3)
                                        .padding()
                                        .background(.blue)
                                        .foregroundStyle(.white)
                                        .cornerRadius(12)
                                }
                            } else {
                                Text("Waiting for the host to start the next game.")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    
                    Button {
                        gm.sendDataTo(data: GameData(messageType: .disconnected, data: [:]))
                        gm.match?.disconnect()
                        gm.match = nil
                        dismiss()
                    } label: {
                        Text("Back to Menu")
                            .font(.headline)
                            .frame(width: geo.size.width * 0.3)
                            .padding()
                            .background(.red)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .cornerRadius(20)
                .padding()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview(traits: .landscapeLeft) {
    let gm = GameManager()
    gm.playerScoreDict = [
        "Player 1": [3, 2, 1],
        "Player 2": [1, 4, 2],
        "Player 3": [2, 1, 3]
    ]
    gm.isHost = true
    return GameOverView(gm: gm)
        .environment(\.locale, Locale(identifier: "cs-CZ"))
}
