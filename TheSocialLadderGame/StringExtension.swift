//
//  StringExtension.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 29.12.2024.
//

import Foundation

extension String {
    func removeSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
