//
//  AuthEnum.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 07.01.2025.
//

import Foundation

enum PlayerAuthState: String {
    case authenticating = "Logging in to Game Center..."
    case unauthenticated = "Please sign in to Game Center to play."
    case authenticated = ""
    
    case error = "There was an error logging into Game Center."
    case restricted = "You're not allowed to play multiplayer games!"
}
