//
//  SelectGameModeView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI

struct SelectGameModeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var gameManager: GameManager
    
    @State private var showMatchView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.left")
                                    .foregroundStyle(Color.textGray)
                                Text("Go Back")
                                    .foregroundStyle(Color.white.opacity(0.9))
                            }
                            .padding(13)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.cardBlue)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 50)
                    .padding(.top, 25)
                    
                    
                    HStack(spacing: 50) {
                        ForEach(0..<2, id: \.self) { id in
                            ZStack(alignment: .center) {
                                Color.cardBlue
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.cardBlue)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.activeBlue.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                VStack(alignment: .center) {
                                    Image(systemName: id == 0 ? "house.fill" : "wifi.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .imageScale(.large)
                                        .foregroundColor(.white)
                                        .shadow(color: Color.activeBlue.opacity(0.5), radius: 10, x: 0, y: 0)
                                    
                                    Text(id == 0 ? "LOCAL" : "ONLINE")
                                        .font(.title)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .minimumScaleFactor(0.5)
                            }
                            .onTapGesture {
                                if id == 0 {
                                    gameManager.createLobby(with: .nearbyOnly) // local multiplayer
                                } else {
                                    gameManager.createLobby(with: .inviteOnly) // online mutliplayer
                                }
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .padding(50)
                }
                .background(Color.darkNavy)
            }
            .fullScreenCover(isPresented: $showMatchView, content: {
                MatchView(gameManager: gameManager)
            })
            .onChange(of: gameManager.gameState, { newState, _ in
                if newState == .choosingQuestions {
                    showMatchView = true
                }
            })
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
    }
}
#Preview(traits: .landscapeRight) {
    SelectGameModeView(gameManager: GameManager())
}
