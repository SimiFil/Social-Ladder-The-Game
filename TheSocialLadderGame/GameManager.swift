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
    var hostID: String = ""

    /// players
    @Published var players: [GKPlayer] = []
    var playerOrder: [String] = []
    var chosenPlayerID: String = ""
    var chosenPlayerOrder: [String] = []
    @Published var chosenPlayerName: String = ""
    @Published var playerCardsOrder: [String] = []
    @Published var receivedResponsesCount: Int = 0
    
    /// score
    @Published var playerOrderDict: [String:[String]] = [:] // host tracks -> ["playerID":["playerID", "playerID", ...]
    @Published var playerScoreDict: [String:[Int]] = [:] // host tracks -> ["playerID":[5, 0, 10]] /// points each round
    
    /// questions
    var questions: [String] = []
    var usedQuestions: [String] = []
    @Published var currentQuestion: String?
    
    /// game state and auth state
    @Published var gameState: GameState = .waitingForPlayers
    @Published var roundState: RoundState = .roundStart
    @Published var playerAuthState: PlayerAuthState = .unauthenticated
    
    /// other
    @Published var errorMessage: String?
    @Published var showGameCenterSettings: Bool = false
    @Published var showMatchView: Bool = false
    
    /// time
    @Published var timeRemaining: Int = 120 // 2 minutes to play // FIXME: change to constant mby
    private var syncTimer: Timer? // my timer
    
    /// rounds/players
    @Published var currentRound: Int = 0
    let minPlayers: Int = 2 // MARK: MIN_PLAYERS
    let maxPlayers: Int = 8 // MARK: MAX_PLAYERS
    @Published var isLockedIn: Bool = false
    var playersLockedIn: Int = 0
    
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
        hostID = localPlayer.gamePlayerID
        
        guard let rootViewController = self.rootViewController else { return }
        
        let viewController = GKMatchmakerViewController(matchRequest: request)
        viewController?.matchmakerDelegate = self
        viewController?.matchmakingMode = mode
//        viewController?.language = LanguageManager.shared.currentLanguage
        
        rootViewController.present(viewController!, animated: true)
    }
    
    // MARK: Join Lobby
    func joinLobby(_ inviteToAccept: GKInvite) {
        guard let rootViewController = self.rootViewController else { return }
        
        // FIXME: add dismiss a viewController if trying to host a lobby...
        if rootViewController.presentedViewController != nil {
            // A view controller is being shown
        }
        
        isHost = false
        print("Joining lobby as player: \(localPlayer.displayName), isHost: \(isHost)")
        
        let viewController = GKMatchmakerViewController(invite: inviteToAccept)
        viewController?.matchmakerDelegate = self
        
        rootViewController.present(viewController!, animated: true)
    }
    
    // MARK: Start round timer
    func startRoundTimer(time: Int) {
        timeRemaining = time
        
        if isHost {
            syncTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.timeRemaining -= 1
                
                let gameData = GameData(
                    messageType: .timerSync,
                    data: ["timeRemaining": String(self.timeRemaining)]
                )
                self.sendDataTo(data: gameData)
                
                // if all player lock in their answers before the timer runs out
                if playersLockedIn == players.count {
                    self.syncTimer?.invalidate()
                    print("round ENDED")
                    roundState = .roundEnd
                    sendDataTo(data: GameData(messageType: .roundState, data: ["roundEnded":""]))                    
                    playersLockedIn = 0
                }
                
                if self.timeRemaining <= 0 {
                    self.syncTimer?.invalidate()
                    
                    if roundState == .playing {
                        print("round ENDED")
                        roundState = .roundEnd
                        sendDataTo(data: GameData(messageType: .roundState, data: ["roundEnded":""]))
                        isLockedIn = true
                    } else if roundState == .roundEnd {
                        print("round STARTS")
                        roundState = .playing
                        playRound()
                    }
                }
            }
        }
    }
    
    // MARK: Choose question deck
    private func chooseQuestionSet() {
        guard isHost else { return }
        
        gameState = .choosingQuestions
        
        let gameData = GameData(messageType: .choosingDeck, data: [:])
        sendDataTo(data: gameData)
    }
    
    // MARK: Picking player order in which will players be chosen
    private func pickPlayerOrderForMatch() {
        for player in players {
            let playerID = player.gamePlayerID
            playerOrder.append(playerID)
        }
        
        playerOrder.shuffle()
    }
    
    // MARK: Choose question for round
    private func chooseQuestion() {
        if questions.count == 0 {
            questions = usedQuestions
        }
        
        // remove last used questions from questions so that they do NOT repeat
        if currentRound != 0 {
            print(currentRound)
            print("used questions: \(usedQuestions)")
            questions.removeAll(where: { $0 == usedQuestions.last })
        }
        
        // choose current question
        currentQuestion = questions.randomElement()
        
        // append it to the used ones
        // we can force because there wont be an option for an empty array
        usedQuestions.append(currentQuestion!)
    }
    
    // MARK: Initialize player score dict
    func initializePlayerScoreDict() {
        for player in players {
            playerScoreDict[player.displayName] = []
        }
    }
    
    // MARK: Resolve score
    func resolveScore() {
        let chosenPlayerOrderArray: [String] = playerOrderDict[chosenPlayerName]!
        
        print("chosenPlayerOrderArray: \(chosenPlayerOrderArray)")
        self.chosenPlayerOrder = chosenPlayerOrderArray
        sendDataTo(data: GameData(messageType: .chosenPlayerOrder, data: ["chosenPlayerOrder":chosenPlayerOrderArray.joined(separator: ",")]))
        
        var scoreMSG: String = ""
        
        // if the chosenPlayer doesn't play give him -1
        // and all the other player +1
        if Set(chosenPlayerOrderArray).count == 1 {
            for player in self.players {
                let playerName: String = player.displayName
                
                if playerName == chosenPlayerName {
                    playerScoreDict[playerName]?.append(-1)
                    scoreMSG.append("\(playerName):-1")
                } else {
                    playerScoreDict[playerName]?.append(1)
                    scoreMSG.append("\(playerName):1")
                }
                
                scoreMSG.append(",")
            }
            
            sendDataTo(data: GameData(messageType: .playerScore, data: ["playerScore":scoreMSG]))
            return
        }
        
        for (playerName, playerArray) in playerOrderDict {
            if playerName == chosenPlayerName {
                continue
            }
            
            guard chosenPlayerOrderArray.count == playerArray.count else {
                print("Error - The arrays are not the same length")
                return
            }
            
            var score = 0
            
            for (idx, name) in chosenPlayerOrderArray.enumerated() {
                if (name == " " && playerArray[idx] != " ") || name == playerArray[idx] {
                    score += 1
                }
            }
            
            playerScoreDict[playerName]?.append(score == players.count ? score + 1 : score)
            if let lastScore = playerScoreDict[playerName]?.last {
                scoreMSG.append("\(playerName):\(lastScore),")
            }
        }
        
        // FIXME: later change the int array to double perhaps
        var chosenPlayerScore = players.count
        for (key, value) in playerScoreDict {
            if key != chosenPlayerName {
                chosenPlayerScore -= value.last ?? 0 / players.count
            }
        }
        playerScoreDict[chosenPlayerName]?.append(Int(chosenPlayerScore))
        scoreMSG.append("\(chosenPlayerName):\(Int(chosenPlayerScore))")
        
        // send score to all other players
        sendDataTo(data: GameData(messageType: .playerScore, data: ["playerScore":scoreMSG]))
    }
    
    // MARK: View func for points showing (+1, -1, 0)
    func calculatePoints() -> [String] {
        var result: [String] = []
        
        if Set(chosenPlayerOrder).count == 1 {
            for player in players {
                result.append("+")
            }
        }
        
        for (idx, name) in chosenPlayerOrder.enumerated() {
            if playerCardsOrder[idx] == " " {
                result.append("0")
                continue
            }
            
            if (name == " " && playerCardsOrder[idx] != " ") || name == playerCardsOrder[idx] {
                result.append("1")
            } else {
                result.append("0")
            }
        }
        
        return result
    }
    
    // MARK: Play round
    func playRound() {
        guard players.count >= minPlayers else { return }
        
        if currentRound == self.players.count {
            print("GAME ENDED")
            gameState = .finished
            sendDataTo(data: GameData(messageType: .gameEnded, data: [:]))
            return
        }
        
        // set received repsponses count to 0
        isLockedIn = false
        playersLockedIn = 0
        receivedResponsesCount = 0
        
        roundState = .playing
        sendDataTo(data: GameData(messageType: .roundState, data: ["roundPlaying":""]))
        
        // chosen player
        chosenPlayerID = playerOrder[currentRound]
        chosenPlayerName = players.first(where: { $0.gamePlayerID == chosenPlayerID })!.displayName
        sendDataTo(data: GameData(messageType: .chosenPlayerName, data: ["chosenPlayerName": chosenPlayerName]))
        sendDataTo(data: GameData(messageType: .chosenPlayerID, data: ["chosenPlayerID": chosenPlayerID]))
        
        // pick question and send it to all players
        startRoundTimer(time: Constants.roundTime)
        chooseQuestion()
        sendDataTo(data: GameData(messageType: .chosenQuestion, data: ["currentQuestion":currentQuestion ?? "No question found"]))
        
        currentRound += 1
    }
    
    // MARK: reset game stats
    private func resetGameStats() {
        syncTimer?.invalidate()
        syncTimer = nil
        currentRound = 0
        playersLockedIn = 0
        playerOrder.removeAll()
        playerOrderDict.removeAll()
        playerScoreDict.removeAll()
    }
    
    // MARK: Start game func
    func startMatch(with questionsType: QuestionsType) {
        guard isHost else {
            print("Only host can start the match")
            return
        }
        
        // refresh all stats
        resetGameStats()
        
        // send all players who the host is
        sendDataTo(data: GameData(messageType: .hostID, data: ["hostID":localPlayer.gamePlayerID]))
        
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
        
        playRound()
//        if playRound() == false {
//            syncTimer?.invalidate()
//        }
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
    
    func getSortedScores() -> [(key: String, value: [Int])] {
        return playerScoreDict.sorted { first, second in
            let firstTotal = first.value.reduce(0, +)
            let secondTotal = second.value.reduce(0, +)
            return firstTotal > secondTotal
        }
    }
}
