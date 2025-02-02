//
//  LeaderboardVIew.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack {
                Text("go back")
                    .onTapGesture {
                        dismiss()
                    }
                
                Text("Leaderboard")
                
                HStack {
                    Text("Round")
                        .font(.title2)
                    
                    ForEach(0..<gameManager.players.count, id: \.self) { i in
                        Text("\(i)")
                    }
                }
                
                ForEach(gameManager.players, id: \.self) { pl in
                    let playerName = pl.displayName
                    
                    HStack {
                        Text("\(playerName)")
                        
                        if let roundPoints = gameManager.playerScoreDict[playerName], !roundPoints.isEmpty {
                            let totalScore = roundPoints.reduce(0, +)
                            
                            ForEach(roundPoints, id: \.self) { score in
                                HStack {
                                    Text("\(score)")
                                }
                            }
                            
                            Text("\(totalScore)")
                        }
                    }
                }
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    LeaderboardView(gameManager: GameManager())
}
