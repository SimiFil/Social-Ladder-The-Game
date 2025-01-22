//
//  GameManager+GKMatchDelegate.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 10.01.2025.
//

import Foundation
import GameKit

extension GameManager: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        do {
            let gameData = try JSONDecoder().decode(GameData.self, from: data)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                print("Received game message: \(gameData.messageType) from \(player.displayName)")
                
                switch gameData.messageType {
                case .choosingDeck:
                    self.gameState = .choosingQuestions
                    self.showMatchView = true
                case .startGame:
                    self.gameState = .playing
                    self.showMatchView = true
                case .playerChoice:
                    if let playerId = gameData.data["playerId"] {
                        self.isTheChosenOne = playerId == self.localPlayer.gamePlayerID
                    }
                case .playerOrder:
                    if let orderString = gameData.data["order"] {
                        self.playerOrder = orderString.split(separator: ",").map(String.init)
                    }
                case .roundEnd:
                    self.currentRound += 1
                case .playerJoined, .playerLeft:
                    print("do nothing for now...")
                }
            }
        } catch {
            print("Failed to process game data: \(error)")
            errorMessage = "Failed to process game data: \(error.localizedDescription)"
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("\n--- Connection State Change ---")
            print("Player \(player.displayName) state: \(state)")
            print("Local player: \(self.localPlayer.displayName)")
            print("Is host: \(self.isHost)")
            
            switch state {
            case .connected:
                if !self.players.contains(player) {
                    self.players.append(player)
                    print("Player added to list")
                }
                
                if self.isHost {
                    print("Host sending current game state")
                    let gameData = GameData(
                        messageType: .choosingDeck,
                        data: [:]
                    )
                    self.sendDataToAllPlayers(data: gameData)
                }
            
            case .disconnected:
                self.players.removeAll { $0 == player }
                print("Player removed, remaining: \(self.players.map { $0.displayName })")
                
                if self.players.count < self.minPlayers {
                    self.errorMessage = "Not enough players to continue. Need at least \(self.minPlayers) players."
                    self.gameState = .waitingForPlayers
                }
                
            default:
                break
            }
            
            print("Final players count: \(self.players.count)")
        }
    }
}
