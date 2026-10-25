import SwiftUI

struct JoystickView: View {
    var onChange: (CGVector) -> Void
    private let size: CGFloat = 130
    @State private var offset = CGSize.zero

    var body: some View {
        ZStack {
            Circle().fill(.ultraThinMaterial).frame(width: size, height: size)
            Circle().fill(Color.accentColor).frame(width: 52, height: 52).offset(offset)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { g in
                    let r = size / 2 - 26
                    let d = hypot(g.translation.width, g.translation.height)
                    let k = d > r ? r / d : 1
                    offset = CGSize(width: g.translation.width * k, height: g.translation.height * k)
                    onChange(CGVector(dx: offset.width / r, dy: -offset.height / r))
                }
                .onEnded { _ in offset = .zero; onChange(.zero) }
        )
    }
}
