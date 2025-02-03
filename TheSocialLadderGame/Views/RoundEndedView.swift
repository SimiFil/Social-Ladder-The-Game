//
//  RoundEndedView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 27.01.2025.
//

import SwiftUI

// FIXME: finish this struct
struct RoundEndedView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .center) {
            Text("time remaining: \(gameManager.timeRemaining)")
        }
        .onAppear {
            gameManager.startRoundTimer(time: 30)
        }
    }
}

#Preview(traits: .landscapeRight) {
    RoundEndedView(gameManager: GameManager())
}
