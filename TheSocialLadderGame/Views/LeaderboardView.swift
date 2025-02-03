//
//  LeaderboardVIew.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI
import GameKit

struct LeaderboardView: View {
    @ObservedObject var gameManager: GameManager
    @State var isLeading: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppBackground()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        GoBackButton()
                        
                        Spacer()
                        
                        HStack {
                            Text("Leaderboard")
                            Image(systemName: "trophy")
                        }
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                    .padding(.top, geo.size.width/30)
                    
                    // MARK: leaderboard table
                    ScrollView {
                        VStack(spacing: 0) {
                            // MARK: header
                            HStack(alignment: .center) {
                                Text("Player")
                                    .frame(width: geo.size.width * 0.2, alignment: .leading)
                                
                                ForEach(0..<gameManager.players.count, id: \.self) { round in
                                    Text("R\(round + 1)")
                                        .frame(width: 50)
                                }
                                
                                Text("Total")
                                    .frame(width: 60)
                            }
                            .font(.headline)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .background(.ultraLightBlue)
                            
                            // MARK: player rows
                            ForEach(Array(gameManager.getSortedScores().enumerated()), id: \.element.key) { index, item in
                                let playerName = item.key
                                let scores = item.value
                                
                                HStack(alignment: .center) {
                                    // player name
                                    Text(playerName)
                                        .lineLimit(1)
                                        .frame(width: geo.size.width * 0.2, alignment: .leading)
                                    
                                    // scores
                                    if !scores.isEmpty {
                                        ForEach(scores, id: \.self) { score in
                                            Text("\(score)")
                                                .frame(width: 50)
                                        }
                                        
                                        // fill empty rounds with dash
                                        ForEach(scores.count..<gameManager.players.count, id: \.self) { _ in
                                            Text("-")
                                                .frame(width: 50)
                                        }
                                        
                                        // total points
                                        Text("\(scores.reduce(0, +))")
                                            .fontWeight(.bold)
                                            .frame(width: 60)
                                    } else {
                                        // show dashes for players with no scores
                                        ForEach(0..<gameManager.players.count, id: \.self) { _ in
                                            Text("-")
                                                .frame(width: 50)
                                        }
                                        
                                        Text("0")
                                            .fontWeight(.bold)
                                            .frame(width: 60)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .foregroundStyle(index == 0 ? .yellow : .white)
                                
                                if index != gameManager.players.count - 1 {
                                    Divider()
                                        .frame(width: geo.size.width/2.5)
                                        .padding(.vertical, 2)
                                }
                            }
                        }
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                        .padding()
                    }
                }
            }
        }
    }
}

// Preview
#Preview(traits: .landscapeRight) {
    let gm = GameManager()
    
    gm.players = [
        GKPlayer(),
        GKPlayer(),
        GKPlayer(),
        GKPlayer(),
        GKPlayer(),
        GKPlayer(),
        GKPlayer(),
        GKPlayer()
    ]
    gm.playerScoreDict = [
        "Player 1": [3, 2, 1],
        "Player 2": [1, 4, 2],
        "Player 3": [2, 1, 3]
    ]
    return LeaderboardView(gameManager: gm)
}
