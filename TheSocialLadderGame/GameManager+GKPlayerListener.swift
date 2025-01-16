//
//  GameManager+GKPlayerListener.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 12.01.2025.
//

import Foundation
import GameKit
import SwiftUI

extension GameManager: GKLocalPlayerListener {
    /// Handles when the local player sends requests to start a match with other players.
    func player(_ player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        print("\n\nSending invites to other players.")
    }
    
    /// Presents the matchmaker interface when the local player accepts an invitation from another player.
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        // Present the matchmaker view controller in the invitation state.
        joinLobby(invite)
    }
}
