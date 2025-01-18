//
//  QuestionType.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 09.01.2025.
//

import Foundation

// MARK: Question Types
enum QuestionsType: String, CaseIterable {
    case basicQuestions = "basicQuestions"
    case partyQuestions = "partyQuestions"
    case wildQuestions = "wildQuestions"
    case customQuestions = "customQuestions"
    
    init?(fromString string: String) {
        switch string {
        case "basicquestions":
            self = .basicQuestions
        case "partyquestions":
            self = .wildQuestions
        case "wildQuestions":
            self = .wildQuestions
        case "customQuestions":
            self = .customQuestions
        default:
            return nil
        }
    }
    
    var name: String {
        switch self {
        case .basicQuestions:
            "Basic Questions"
        case .partyQuestions:
            "Party Questions"
        case .wildQuestions:
            "Wild Questions"
        case .customQuestions:
            "Create Custom Questions"
        }
    }
}
