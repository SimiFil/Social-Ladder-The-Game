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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//            .onAppear {
//                print(gameManager.roundState)
//                
//                if gameManager.roundState == .roundEnd {
//                    if gameManager.isHost {
//                        gameManager.playerOrderDict[gameManager.localPlayer.displayName] = Array(dropZoneContents.values)
//                    } else {
//                        guard let host = gameManager.players.first(where: { $0.gamePlayerID == gameManager.hostID }) else {
//                            print("Error: Could not find host player")
//                            return
//                        }
//                        
//                        let playerCardsOrderStr: String = Array(dropZoneContents.values).joined(separator: ",")
//                        print(playerCardsOrderStr)
//                        gameManager.sendDataTo(players: [host], data: GameData(messageType: .playerChoice, data: ["playerGameOrder":playerCardsOrderStr]))
//                    }
//                }
//            }
    }
}

#Preview(traits: .landscapeRight) {
    RoundEndedView(gameManager: GameManager())
}
