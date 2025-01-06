//
//  Game.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 05.01.2025.
//

import Foundation
import GameKit

// MARK: Question Types
enum QuestionsType: String {
    case basicQuestions = "basicQuestions"
    case partyQuestions = "partyQuestions"
    case wildQuestions = "wildQuestions"
    case customQuestions = "customQuestions"
}

// MARK: Game State
enum GameState: String {
    case waitingForPlayers
    case choosingQuestions
    case playing
    case talking
    case finished
}

// MARK: Game Class
class Game: ObservableObject {
    // game params
    @Published var roundTime: Int = 120 // 2 minutes to play
    @Published var talkTime: Int = 300 // 5 minutes to talk about it
    var maxRounds: Int = 8
    var currentRound: Int = 0
    var players: [Player] = []
    var questions: [String] = [] // lobby leader will choose the dataset
    
    // load question
    func loadQuestions(from type: QuestionsType) -> Bool {
        guard let url = Bundle.main.url(forResource: type.rawValue, withExtension: "json") else {
            print("Could not find file")
            return false
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questionJSON = try decoder.decode([String: [Question]].self, from: data)
            
            if let questionArray = questionJSON[type.rawValue] {
                questions = questionArray.map { $0.question }
                print(questions)
                questions.shuffle()
                return true
            }
            
            return false
            
        } catch {
            print("Error loading questions: \(error)")
            return false
        }
    }
    
    // You'll need this small structure to decode the JSON properly
    private struct Question: Codable {
        let question: String
    }
}
