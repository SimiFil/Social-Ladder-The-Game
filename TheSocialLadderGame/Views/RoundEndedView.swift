//
//  RoundEndedView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 27.01.2025.
//

import SwiftUI

struct RoundEndedView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .center) {
            Text("time remaining: \(gameManager.timeRemaining)")
        }
        .onAppear {
            gameManager.startRoundTimer(time: 30) // FIXME: fix the timer
        }
    }
}

#Preview(traits: .landscapeRight) {
    RoundEndedView(gameManager: GameManager())
}
