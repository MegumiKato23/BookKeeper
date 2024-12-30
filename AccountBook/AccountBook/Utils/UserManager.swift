import Foundation
import SwiftUI

class UserManager: ObservableObject {
    // 单例模式
    static let shared = UserManager()
    private init() {
        // 从 UserDefaults 恢复用户状态
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserResponse.self, from: userData) {
            self.currentUser = user
            self.isLoggedIn = true
        }
    }
    
    // 发布用户状态变化
    @Published var currentUser: UserResponse?
    @Published var isLoggedIn: Bool = false
    
    // 登录
    func login(user: UserResponse) {
        self.currentUser = user
        self.isLoggedIn = true
        
        // 保存用户信息到 UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    // 登出
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
        
        // 清除 UserDefaults 中的用户信息
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    // 更新用户信息
    func updateUser(_ user: UserResponse) {
        self.currentUser = user
        
        // 更新 UserDefaults 中的用户信息
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
}
