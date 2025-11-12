import SwiftUI

extension View {
    /// 添加边框到视图的指定边
    /// - Parameters:
    ///   - width: 边框宽度
    ///   - edges: 要添加边框的边（.top, .bottom, .leading, .trailing）
    ///   - color: 边框颜色
    func border(width: CGFloat, edges: Set<Edge>, color: Color) -> some View {
        overlay(
            EdgeBorder(width: width, edges: edges, color: color)
        )
    }
}

struct EdgeBorder: View {
    let width: CGFloat
    let edges: Set<Edge>
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            if edges.contains(.top) {
                color.frame(height: width)
            }

            HStack(spacing: 0) {
                if edges.contains(.leading) {
                    color.frame(width: width)
                }

                Spacer()

                if edges.contains(.trailing) {
                    color.frame(width: width)
                }
            }

            if edges.contains(.bottom) {
                color.frame(height: width)
            }
        }
    }
}

