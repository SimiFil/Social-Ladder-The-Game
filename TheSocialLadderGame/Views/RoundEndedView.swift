//
//  RoundEndedView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 27.01.2025.
//

import SwiftUI
import GameKit

struct RoundEndedView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppBackground()
                
                VStack(spacing: 35) {
                    VStack(spacing: 8) {
                        Text(gameManager.chosenPlayerID == gameManager.localPlayer.gamePlayerID ? "MY ORDER" : "CHOSEN PLAYER'S ORDER")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.bottom, 5)
                        
                        HStack(spacing: 20) {
                            ForEach(Array(gameManager.chosenPlayerOrder.enumerated()), id: \.offset) { _, name in
                                ModernPlayerCard(name: name)
                            }
                        }
                        .padding(.horizontal)
                        .minimumScaleFactor(0.5)
                        
                    }
                    
                    if gameManager.chosenPlayerID != gameManager.localPlayer.gamePlayerID {
                        VStack(spacing: 8) {
                            Text("MY ORDER")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.bottom, 5)
                            
                            HStack(spacing: 20) {
                                ForEach(Array(zip(gameManager.playerCardsOrder, gameManager.calculatePoints()).enumerated()), id: \.element.0) { _, element in
                                    ModernPlayerCard(name: element.0, score: element.1)
                                }
                                
                                if let myScore = gameManager.playerScoreDict[gameManager.localPlayer.displayName]?.last,
                                   myScore > gameManager.players.count {
                                    BonusPointCard()
                                }
                            }
                            .padding(.horizontal)
                            .minimumScaleFactor(0.5)
                        }
                    }
                }
                .padding(.top)
                .minimumScaleFactor(0.8)
            }
        }
        .onAppear {
            gameManager.startRoundTimer(time: Constants.talkingTime)
        }
    }
}

struct ModernPlayerCard: View {
    let name: String
    var score: String?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        colors: [Color.cardBlue.opacity(0.8), Color.ultraLightBlue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 10)
            
            VStack(spacing: 10) {
                if let score = score {
                    ScoreBadge(score: score)
                }
            }
                
            VStack {
                Text(name == " " ? "Empty" : name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        }
        .frame(width: 80, height: 90)
    }
}

// MARK: Badge above the player card
struct ScoreBadge: View {
    let score: String
    
    var body: some View {
        Image(systemName: score == "1" || score == "+" ? "checkmark" : "xmark")
            .font(.caption)
            .foregroundColor(.customWhitesmoke)
            .fontWeight(.bold)
            .padding(10)
            .background(
                Circle()
                    .fill(score == "1" || score == "+" ? .green : .red)
                    .shadow(color: .black.opacity(0.2), radius: 3)
            )
            .offset(x: 38, y: -40)
    }
}

// MARK: Bonus Point Card - if the user gets all players correctly
struct BonusPointCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraLightBlue.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.yellow.opacity(0.5), lineWidth: 1)
                )
            
            VStack(spacing: 5) {
                if #available(iOS 18.0, *) {
                    Image(systemName: "star.fill")
                        .font(.headline)
                        .foregroundStyle(.yellow)
                        .symbolEffect(.bounce, options: .repeating.speed(0.5))
                } else {
                    Image(systemName: "star.fill")
                        .font(.headline)
                        .foregroundStyle(.yellow)
                        .symbolEffect(.bounce, value: true)
                }
                
                Text("+1")
                    .font(.headline)
                    .foregroundStyle(.yellow)
            }
        }
        .frame(width: 80, height: 90)
    }
}

#Preview(body: {
    BonusPointCard()
        .preferredColorScheme(.dark)
})

#Preview(traits: .landscapeRight) {
   let gm = GameManager()
   gm.chosenPlayerOrder = ["Player 1", "Player 2", " ", "Player 4"]
   gm.playerCardsOrder = ["Player 1", " ", "Player 3", "Player 4"]
   gm.playerScoreDict = ["Current Player": [3]]
   gm.players = [GKPlayer()]
   gm.chosenPlayerID = "123"
   return RoundEndedView(gameManager: gm)
}
