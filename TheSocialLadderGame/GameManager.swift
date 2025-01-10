//
//  Game.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 05.01.2025.
//

import Foundation
import GameKit

// MARK: Game State
enum GameState: String {
    case waitingForPlayers
    case choosingQuestions
    case playing
    case talking
    case finished
}

// MARK: Game Class
class GameManager: NSObject, ObservableObject {
    // game params
    @Published var showGameCenterSettings: Bool = false
    @Published var roundTime: Int = 120 // 2 minutes to play
    @Published var talkTime: Int = 300 // 5 minutes to talk about it
    @Published var players: [GKPlayer] = []
    @Published var questions: [String] = []
    @Published var currentQuestion: String?
    @Published var gameState: GameState = .waitingForPlayers
    @Published var playerAuthState: PlayerAuthState = .unauthenticated
    @Published var isHost: Bool = false
    @Published var isTimeKeeper: Bool = false // so that the timer runs only on one device
    @Published var isTheChosenOne: Bool = false // one player will be chosen each round to be the "leader" of the round
    @Published var errorMessage: String?
    
    @Published var currentRound: Int = 0
    let maxRounds: Int = 10 // MARK: MAX_ROUNDS
    let minPlayers: Int = 4 // MARK: MIN_PLAYERS
    let maxPlayers: Int = 8 // MARK: MAX_PLAYERS
    
    private var match: GKMatch?
    private var gameTimer: Timer?
    private let localPlayer = GKLocalPlayer.local // the player on the current device
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    // start game func
    func startGame() -> Void {
        // TODO
    }
    //
    //    func hostGame() {
    //        let request = GKMatchRequest()
    //        request.minPlayers = minPlayers  // Set minimum to 4 players
    //        request.maxPlayers = maxPlayers
    //
    //        guard let viewController = GKMatchmakerViewController(matchRequest: request) else {
    //            errorMessage = "Failed to create match"
    //            return
    //        }
    //        viewController.matchmakerDelegate = self
    //        rootViewController?.present(viewController, animated: true)
    //        isHost = true
    //    }
    //
    // MARK: Load questions func
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
    
    // MARK: Game Center Authentication
    func authenticatePlayer() {
        localPlayer.authenticateHandler = { [self] viewController, error in
            // show game center View
            if let viewController = viewController {
                self.rootViewController?.present(viewController, animated: true)
                return
            }
            
            if let error = error {
                switch error._domain {
                case "GKErrorDomain":
                    switch error._code {
                    case 2: // User canceled or disabled
                        self.playerAuthState = .unauthenticated
                        self.errorMessage = "Please enable Game Center in Settings to play."
                    case 6: // Not authenticated
                        self.showGameCenterSettings = true
                    default:
                        self.playerAuthState = .error
                        self.errorMessage = error.localizedDescription
                    }
                default:
                    self.playerAuthState = .error
                    self.errorMessage = error.localizedDescription
                }
                print("Authentication error: \(error.localizedDescription)")
                return
            }
            
            if localPlayer.isAuthenticated {
                if localPlayer.isMultiplayerGamingRestricted {
                    self.playerAuthState = .restricted
                    self.errorMessage = "Multiplayer gaming is restricted on this device."
                } else {
                    self.playerAuthState = .authenticated
                    print("Player authenticated: \(localPlayer.displayName)")
                }
            } else {
                self.playerAuthState = .unauthenticated
                print("Player not authenticated")
            }
        }
        
    }
    
    private struct Question: Codable {
        let question: String
    }
    
    // MARK: Picking player whose order will be important for that round
    func pickPlayerForRound(from players:[GameKit.GKMatchedPlayers]) {
        // TODO
    }
}
