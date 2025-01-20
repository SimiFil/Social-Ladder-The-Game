//
//  SelectDeckView.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 18.01.2025.
//

import SwiftUI

struct SelectDeckView: View {
    @ObservedObject var gameManager: GameManager
    @State var selectedDeck: String = "basicQuestions"
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Select Deck")
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
                            id: idx, type: qt,
                            isSelected: selectedDeck == String(describing: qt),
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedDeck = String(describing: qt)
                                }
                                
                                if let questionType = QuestionsType(fromString: selectedDeck) {
                                    gameManager.startMatch(with: questionType)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    SelectDeckView(gameManager: GameManager())
}
