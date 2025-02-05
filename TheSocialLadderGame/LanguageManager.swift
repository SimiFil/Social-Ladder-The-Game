//
//  LanguageManager.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 05.02.2025.
//

import Foundation

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: SettingsKeys.language)
            print(currentLanguage)
        }
    }
    
    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: SettingsKeys.language) ?? getDefaultLanguage()
    }
}
