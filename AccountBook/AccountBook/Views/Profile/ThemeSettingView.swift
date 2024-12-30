import SwiftUI

struct ThemeSettingView: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Form {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(AccentColor.allCases, id: \.self) { color in
                            Button(action: { themeManager.accentColor = color }) {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 45, height: 45)
                                    .overlay {
                                        if color == themeManager.accentColor {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            } header: {
                Text("主题颜色")
            }
            
            // 预览
            Section {
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(themeManager.accentColor.color)
                        Text("账单明细")
                            .foregroundColor(themeManager.accentColor.color)
                    }
                    
                    Button("添加账单") {}
                        .buttonStyle(.borderedProminent)
                        .tint(themeManager.accentColor.color)
                }
                .padding(.vertical, 5)
            } header: {
                Text("预览效果")
            }
        }
        .navigationTitle("主题设置")
        .navigationBarTitleDisplayMode(.inline)
        .tint(themeManager.accentColor.color)
    }
}

#Preview {
    NavigationView {
        ThemeSettingView()
    }
} 
