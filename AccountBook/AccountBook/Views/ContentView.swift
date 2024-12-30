import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Group {
            if userManager.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager.shared)
        .environmentObject(ThemeManager.shared)
        .tint(ThemeManager.shared.accentColor.color)
}
