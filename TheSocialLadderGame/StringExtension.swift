//
//  StringExtension.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 29.12.2024.
//

import Foundation
import GameKit

extension String {
    func removeSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    func decodePlayersDictString(players: [GKPlayer]) -> [String] {
        let decodedMSG = self.split(separator: ",").map(String.init)
        var resultArray = Array(repeating: " ", count: players.count)
        
        for item in decodedMSG {
            let parts = item.split(separator: ":").map(String.init)
            if parts.count == 2, let index = Int(parts[0]) {
                resultArray[index] = parts[1]
            }
        }
        
        return resultArray
    }
}
