//
//  ToolbarButton.swift
//  TheSocialLadderGame
//
//  Created by Filip Simandl on 07.02.2025.
//

import Foundation
import SwiftUI

// MARK: Toolbar button
struct ToolbarButton: View {
    let iconName: String
    var leaving: Bool = false
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 20))
            .foregroundStyle(leaving ? .black : .textGray)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(leaving ? .red.opacity(0.8) : .black.opacity(0.2))
            )
    }
}
