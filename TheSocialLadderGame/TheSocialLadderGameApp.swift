//
//  TheSocialLadderGameApp.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 23.12.2024.
//

import SwiftUI

@main
struct TheSocialLadderGameApp: App {
    @StateObject private var gameManager = GameManager()
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainPage(gameManager: gameManager)
                .environment(\.locale, Locale(identifier: languageManager.currentLanguage))
        }
    }
}
