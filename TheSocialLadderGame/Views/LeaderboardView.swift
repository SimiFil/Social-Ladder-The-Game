//
//  LeaderboardVIew.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        Text("L")
//        ForEach(gameManager.players, id: \.self) { pl in
//            Text("\(pl.displayName) - points: \(pl.score)")
//        }
    }
}

#Preview(traits: .landscapeRight) {
    LeaderboardView(gameManager: GameManager())
}
