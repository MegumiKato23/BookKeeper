import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var userManager: UserManager
    
    var body: some View {
        TabView {
            NavigationView {
                BillListView()
            }
            .tabItem {
                Label("账单", systemImage: "list.bullet")
            }
            
            NavigationView {
                StatisticsTabView()
            }
            .tabItem {
                Label("统计", systemImage: "chart.pie")
            }
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("我的", systemImage: "person")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserManager.shared)
}
