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
        GeometryReader { geo in
            VStack(alignment: .center) {
                Text("CHOSEN PLAYER'S ORDER")
                ForEach(gameManager.chosenPlayerOrder, id: \.self) { plName in
                    HStack {
                        if plName == " " {
                            Text("Nothing.")
                        } else {
                            Text(plName)
                                .frame(width: 50, height: 10)
                                .padding(.horizontal)
                        }
                    }
                }
                
                Text("MY ORDER")
                ForEach(gameManager.playerCardsOrder, id: \.self) { plName in
                    HStack {
                        if plName == " " {
                            Text("Nothing.")
                        } else {
                            Text(plName)
                                .frame(width: 50, height: 10)
                                .padding(.horizontal)
                        }
                    }
                }
                
                Text("MY SCORE")
                ForEach(gameManager.calculatePoints(), id: \.self) { cardScore in
                    HStack {
                        Text(cardScore)
                            .frame(width: 20, height: 10)
                            .padding(.horizontal)
                    }
                }
                
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .padding(.horizontal)
        }
        .onAppear {
            gameManager.startRoundTimer(time: 30)
        }
    }
}

#Preview(traits: .landscapeRight) {
    RoundEndedView(gameManager: GameManager())
}
