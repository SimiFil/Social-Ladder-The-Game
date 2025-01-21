//
//  GameManager+ GKMatchmakerViewControllerDelegate.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 11.01.2025.
//

import Foundation
import GameKit

extension GameManager: GKMatchmakerViewControllerDelegate {
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        isHost = false
        viewController.dismiss(animated: true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true)
        errorMessage = error.localizedDescription
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        print("Match found with \(match.players.count + 1) players")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
//            viewController.dismiss(animated: true)
            self.match = match
            match.delegate = self
            
            self.players = match.players + [self.localPlayer]
            
            self.showMatchView = true
            
            if self.isHost {
                self.gameState = .choosingQuestions
            } else {
                self.gameState = .waitingForPlayers
            }
            
            // Dismiss after setting up everything
            viewController.dismiss(animated: true)
        }
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, hostedPlayerDidAccept player: GKPlayer) {
        print("Player \(player.displayName) accepted the invitation")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if !self.players.contains(player) {
                self.players.append(player)
                print("Added player \(player.displayName), total players: \(self.players.count)")
                
                // Notify other players about the new player
                let gameData = GameData(messageType: .playerJoined, data: [:])
                if let match = self.match {
                    try? match.sendData(toAllPlayers: JSONEncoder().encode(gameData), with: .reliable)
                }
                
                self.canStartGame = self.players.count >= self.minPlayers
            }
        }
    }
}
