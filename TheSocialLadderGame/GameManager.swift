//
//  Game.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 05.01.2025.
//

import Foundation
import GameKit
import CoreBluetooth

// MARK: Game Class
class GameManager: NSObject, ObservableObject {
    /// who is who
    var isHost: Bool = false

    /// players
    @Published var players: [GKPlayer] = []
    var playerOrder: [String] = []
    var chosenPlayerID: String = ""
    @Published var chosenPlayerName: String = ""
    @Published var playerCardsOrder: [String] = []
    
    /// score
    @Published var playerScoreDict: [String:[String]] = [:]
    @Published var score: Int = 0
    
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
    @Published var timeRemaining: Int = 120 // 2 minutes to play // FIXME: change to constant mby
    private var syncTimer: Timer? // my timer
    @Published var talkTime: Int = 300 // 5 minutes to talk about it
    
    /// rounds/players
    @Published var currentRound: Int = 0
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
    
    // MARK: Start round timer
    func startRoundTimer() {
        timeRemaining = 120
        
        if isHost {
            syncTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.timeRemaining -= 1
                
                let gameData = GameData(
                    messageType: .timerSync,
                    data: ["timeRemaining": String(self.timeRemaining)]
                )
                self.sendDataTo(data: gameData)
                
                // FIXME: handle when timer ends -> send message round end
                if self.timeRemaining <= 0 {
                    self.syncTimer?.invalidate()
                    gameState = .roundEnd
                    sendDataTo(data: GameData(messageType: .roundEnd, data: [:]))
                }
            }
        }
    }
    
    // MARK: Choose question deck
    func chooseQuestionSet() {
        guard isHost else { return }
        
        gameState = .choosingQuestions
        
        let gameData = GameData(messageType: .choosingDeck, data: [:])
        sendDataTo(data: gameData)
    }
    
    // MARK: Picking player order in which will players be chosen
    func pickPlayerOrderForMatch() {
        for player in players {
            let playerID = player.gamePlayerID
            playerOrder.append(playerID)
        }
        
        playerOrder.shuffle()
    }
    
    // MARK: Choose question for round
    func chooseQuestion() {
        if questions.count == 0 {
            questions = usedQuestions
        }
        
        // remove last used questions from questions so that they do NOT repeat
        if currentRound != 0 {
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
        // chosen player
        chosenPlayerID = playerOrder[currentRound]
        chosenPlayerName = players.first(where: { $0.gamePlayerID == chosenPlayerID })!.displayName
        sendDataTo(data: GameData(messageType: .chosenPlayerName, data: ["chosenPlayerName": chosenPlayerName]))
        sendDataTo(data: GameData(messageType: .chosenPlayerID, data: ["chosenPlayerID": chosenPlayerID]))
        
        // pick question and send it to all players
        if isHost {
            startRoundTimer()
            chooseQuestion()
            sendDataTo(data: GameData(messageType: .chosenQuestion, data: ["currentQuestion":currentQuestion ?? "No question found"]))
        }
        
        // if timer runs out -> end round
        if gameState == .roundEnd {
            print("round ended")
            // send my player choice to the host
            
            // host resolves points and distributes them
            
            // host sends the score info to all players
        }
        
        // if player locks in his answers -> end round
        
        currentRound += 1
    }
    
    // MARK: Check cards and resolve score
    
    // MARK: Start game func
    func startMatch(with questionsType: QuestionsType) {
        guard isHost else {
            print("Only host can start the match")
            return
        }
        
        // load questions first
        loadQuestions(from: questionsType)
        print("loading questions from JSON")
        
        // pick player order from all players joined
        pickPlayerOrderForMatch()
        let playerOrderStr = playerOrder.joined(separator: ",")
        let playerOrderData = GameData(messageType: .playerOrder, data: ["playerOrder": playerOrderStr])
        sendDataTo(data: playerOrderData)
        
        // set gameState to playing
        let gameData = GameData(messageType: .startGame, data: [:])
        sendDataTo(data: gameData)
        gameState = .playing
        
        playMatch()
    }
    
    // MARK: Play match
    func playMatch() {
        playRound()
    }
    
    // MARK: Send data to players
    func sendDataTo(players: [GKPlayer]? = nil, data: GameData) {
        guard let match = match else { return }
        
        do {
            let encodedData = try JSONEncoder().encode(data)
            if let msgRecievers = players {
                try match.send(encodedData, to: msgRecievers, dataMode: .reliable)
            } else {
                try match.sendData(toAllPlayers: encodedData, with: .reliable)
            }
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
}
