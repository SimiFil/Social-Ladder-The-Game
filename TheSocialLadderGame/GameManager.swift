//
//  Game.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 05.01.2025.
//

import Foundation
import GameKit
import CoreBluetooth

// MARK: Game State
enum GameState: String, Codable {
    case waitingForPlayers
    case choosingQuestions
    case playing
    case talking
    case finished
}

enum GameMessage: String, Codable {
    case choosingDeck
    case startGame
    case chosenQuestion
    case chosenPlayer
    case roundEnd
    case playerChoice
    case playerJoined
    case playerLeft
}

// MARK: Game Class
class GameManager: NSObject, ObservableObject {
    /// who is who
    @Published var isHost: Bool = false
    @Published var isTimeKeeper: Bool = false // so that the timer runs only on one device
    @Published var isTheChosenOne: Bool = false // one player will be chosen each round to be the "leader" of the round
    
    /// players
    @Published var players: [GKPlayer] = []
    @Published var playerOrder: [GKPlayer] = []
    @Published var playerCardsOrder: [String] = []
    
    /// questions
    var questions: [String] = []
    var usedQuestions: [String] = []
    @Published var currentQuestion: String?
    
    /// game state and auth state
    @Published var gameState: GameState = .waitingForPlayers
    @Published var playerAuthState: PlayerAuthState = .unauthenticated
    
    /// other
    @Published var errorMessage: String?
    @Published var showGameCenterSettings: Bool = false
    @Published var showMatchView: Bool = false
    
    /// time
    @Published var currentRound: Int = 0
    @Published var roundTime: Int = 120 // 2 minutes to play
    @Published var talkTime: Int = 300 // 5 minutes to talk about it
    
    /// min/max
    let maxRounds: Int = 10 // MARK: MAX_ROUNDS
    let minPlayers: Int = 2 // MARK: MIN_PLAYERS
    let maxPlayers: Int = 8 // MARK: MAX_PLAYERS
    
    var match: GKMatch?
    var gameTimer: Timer?
    let localPlayer = GKLocalPlayer.local // the player on the current device
    
    var myName: String {
        localPlayer.displayName
    }
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    // MARK: Find MAtch
    /// GKMatchmakingMode - nearbyOnly or inviteOnly
    func createLobby(with mode: GKMatchmakingMode) {
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        request.inviteMessage = "Join me for a game of \(Constants.gameName)!"
        
        isHost = true
        
        guard let rootViewController = self.rootViewController else { return }
        
        let viewController = GKMatchmakerViewController(matchRequest: request)
        viewController?.matchmakerDelegate = self
        viewController?.matchmakingMode = mode
        
        rootViewController.present(viewController!, animated: true)
    }
    
    // MARK: Join Lobby
    func joinLobby(_ inviteToAccept: GKInvite) {
        guard let rootViewController = self.rootViewController else { return }
        
        isHost = false
        print("Joining lobby as player: \(localPlayer.displayName), isHost: \(isHost)")
        
        let viewController = GKMatchmakerViewController(invite: inviteToAccept)
        viewController?.matchmakerDelegate = self
        
        rootViewController.present(viewController!, animated: true)
    }
    
    // MARK: Choose question deck
    func chooseQuestionSet() {
        guard isHost else { return }
        
        gameState = .choosingQuestions
        
        let gameData = GameData(messageType: .choosingDeck, data: [:])
        sendDataToAllPlayers(data: gameData)
    }
    
    // MARK: Picking player order in which will players be chosen
    func pickPlayerOrderForMatch() {
        playerOrder.append(contentsOf: self.players)
        playerOrder.shuffle()
        print(playerOrder)
    }
    
    // MARK: Choose question for round
    func chooseQuestion() {
        if questions.count == 0 {
            questions = usedQuestions
        }
        
        // remove last used questions from questions so that they do NOT repeat
        if currentRound != 1 {
            questions.removeAll(where: { $0 == usedQuestions[-1] })
        }
        
        // choose current question
        currentQuestion = questions.randomElement()
        
        // append it to the used ones
        // we can force because there wont be an option for an empty array
        usedQuestions.append(currentQuestion!)
    }
    
    // MARK: Play round
    func playRound() {
        gameState = .playing
        isTheChosenOne = playerOrder[currentRound] == localPlayer
        currentRound += 1
        
        if isHost {
            chooseQuestion()
            print("choosing question")
            sendDataToAllPlayers(data: GameData(messageType: .chosenQuestion, data: ["currentQuestion":currentQuestion ?? "No question found"])) // send chosen question to all players
        }
        
        // if timer runs out -> end round
        
        // if player locks in his answers -> end round
    }
    
    // MARK: Start game func
    func startMatch(with questionsType: QuestionsType) {
        guard isHost else {
            print("Only host can start the match")
            return
        }
        
        guard let match = match else {
            errorMessage = "No active match found"
            return
        }
        
        // load questions first
        loadQuestions(from: questionsType)
        print("loading questions from JSON")
        
        // pick player order from all players joined
        pickPlayerOrderForMatch()
        
        do {
            let gameData = GameData(messageType: .startGame, data: [:])
            let encodedData = try JSONEncoder().encode(gameData)
            try match.sendData(toAllPlayers: encodedData, with: .reliable)
            
            print("Starting game with \(players.count) players")
            gameState = .playing
            
            playRound()
        } catch {
            print("Failed to start match: \(error)")
            errorMessage = "Failed to start game: \(error.localizedDescription)"
        }
    }
    
    // MARK: Send data to players
    func sendDataToAllPlayers(data: GameData) {
        guard let match = match else { return }
        
        do {
            let encodedData = try JSONEncoder().encode(data)
            try match.sendData(toAllPlayers: encodedData, with: .reliable)
        } catch {
            errorMessage = "Failed to send game data: \(error.localizedDescription)"
        }
    }
    
    // MARK: Load questions func
    func loadQuestions(from type: QuestionsType) -> Void {
        guard let url = Bundle.main.url(forResource: type.rawValue, withExtension: "json") else {
            print("Could not find file")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questionJSON = try decoder.decode([String: [Question]].self, from: data)
            
            if let questionArray = questionJSON[type.rawValue] {
                questions = questionArray.map { $0.question }
                //                print(questions)
                questions.shuffle()
            }
        } catch {
            print("Error loading questions: \(error)")
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
        
        // Register for real-time invitations from other players.
        GKLocalPlayer.local.register(self)
    }
    
    // MARK: Question struct
    private struct Question: Codable {
        let question: String
    }
}

struct GameData: Codable {
    let messageType: GameMessage
    let data: [String: String]
}
