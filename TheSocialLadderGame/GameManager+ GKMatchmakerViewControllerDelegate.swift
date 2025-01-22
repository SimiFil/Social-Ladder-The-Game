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
        viewController.dismiss(animated: true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true)
        errorMessage = error.localizedDescription
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        print("\nMATCH FOUND")
        print("Local player: \(localPlayer.displayName)")
        print("Is host: \(isHost)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.match = match
            match.delegate = self
            self.players = match.players + [self.localPlayer]
            
            self.showMatchView = true
            self.gameState = .choosingQuestions
            
            viewController.dismiss(animated: true)
        }
    }
}
