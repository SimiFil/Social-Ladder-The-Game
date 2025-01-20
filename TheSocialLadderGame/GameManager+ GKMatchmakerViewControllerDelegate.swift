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
        viewController.dismiss(animated: true)
        self.match = match
        match.delegate = self
        players = match.players // mby remove later
        gameState = .choosingQuestions
    }
}
