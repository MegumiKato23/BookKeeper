import SwiftUI
import Foundation

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("accentColor") var accentColor: AccentColor = .blue {
        didSet {
            objectWillChange.send()
        }
    }
}

// 强调色枚举
enum AccentColor: String, CaseIterable {
    case blue = "蓝色"
    case purple = "紫色"
    case pink = "粉色"
    case red = "红色"
    case orange = "橙色"
    case green = "绿色"
    case teal = "青色"
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .red: return .red
        case .orange: return .orange
        case .green: return .green
        case .teal: return .teal
        }
    }
}
