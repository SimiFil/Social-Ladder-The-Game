import SwiftUI

struct SwipeableStartButton: View {
    let action: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var width: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(.gray.opacity(0.3))
                    .frame(width: geo.size.width, height: 56)
                    .overlay(
                        Text("SWIPE TO START")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    )
                
                // Draggable button
                Circle()
                    .fill(.white)
                    .frame(width: 48, height: 48)
                    .padding(.horizontal, 4)
                    .offset(x: offset)
                    .shadow(radius: 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let maxOffset = geo.size.width - 56 // maxOffset
                                offset = min(max(0, value.translation.width), maxOffset)
                                
//                                print("dragging - current offset: \(offset), max offset: \(maxOffset)")
                            }
                            .onEnded { value in
                                isDragging = false
                                let maxOffset = geo.size.width - 56
                                let threshold = maxOffset * 0.7
                                
//                                print("gesture ended - current offset: \(offset), threshold: \(threshold)")
                                
                                // if the button/circle is across 70% -> do the action
                                if offset >= threshold {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        offset = maxOffset
                                    }
                                    
                                    // Execute the action after animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        action()
                                        print("Action executed")
                                    }
                                } else {
                                    print("not enough")
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        offset = 0
                                    }
                                }
                            }
                    )
            }
        }
        .frame(width: 280, height: 56)
    }
}

#Preview(traits: .landscapeLeft) {
    SwipeableStartButton {
        
    }
}
