import SwiftUI

struct SwipeableStartButton: View {
    let action: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var width: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // background capsule
                Capsule()
                    .fill(.gray.opacity(0.3))
                    .frame(width: geo.size.width, height: 56)
                    .overlay(
                        Text("SWIPE TO START")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                        
                        
                    )
                    .overlay(alignment: .leading) {
                        if offset == 0 {
                            Circle()
                                .fill(.yellow.opacity(0.9))
                                .frame(width: offset + 48, height: 56)
                        } else {
                            Capsule()
                                .fill(.yellow.opacity(0.9))
                                .frame(width: offset + 48, height: 52)
                                .padding(.vertical, 10)
                        }
                    }
                
                // draggable button
                Circle()
                    .fill(.yellow)
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
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        action()
                                    }
                                } else {
//                                    print("not enough")
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
