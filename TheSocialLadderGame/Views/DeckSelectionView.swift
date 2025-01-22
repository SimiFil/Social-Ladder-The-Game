//
//  DeckSelectionView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 18.01.2025.
//

import SwiftUI

struct DeckSelectionView: View {
    @ObservedObject var gameManager: GameManager
    @State var selectedDeck: String = "basicQuestions"
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(alignment: gameManager.isHost ? .leading : .center, spacing: 24) {
                Text(gameManager.isHost ? "Select Deck" : "Waiting For The Host To Select A Deck")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                
                // cards
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 16)
                ], spacing: 16) {
                    ForEach(Array(QuestionsType.allCases.enumerated()), id: \.element) { idx, qt in
                        DeckCard(
                            gameManager: gameManager,
                            id: idx,
                            type: qt,
                            isSelected: selectedDeck == String(describing: qt)
                        ) {
                            print(selectedDeck)
                            selectedDeck = String(describing: qt)
                            gameManager.startMatch(with: qt)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    DeckSelectionView(gameManager: GameManager())
}

