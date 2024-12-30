//
//  AccountBookApp.swift
//  AccountBook
//
//  Created by 周广 on 2024/12/12.
//

import SwiftUI

@main
struct AccountBookApp: App {
    @StateObject private var userManager = UserManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .environmentObject(themeManager)
                .tint(themeManager.accentColor.color)
        }
    }
}
