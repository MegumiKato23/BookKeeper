import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: UserManager
    @StateObject private var userAPI = UserAPI()
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSuccessAlert = false
    
    private var canSubmit: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    var body: some View {
        Form {
            Section {
                SecureField("当前密码", text: $currentPassword)
                    .textContentType(.password)
                
                SecureField("新密码", text: $newPassword)
                    .textContentType(.newPassword)
                
                SecureField("确认新密码", text: $confirmPassword)
                    .textContentType(.newPassword)
            } footer: {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section {
                Button(action: changePassword) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("确认修改")
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(!canSubmit || isLoading)
            }
        }
        .navigationTitle("修改密码")
        .navigationBarTitleDisplayMode(.inline)
        .alert("修改成功", isPresented: $showingSuccessAlert) {
            Button("确定") { dismiss() }
        }
    }
    
    private func changePassword() {
        guard canSubmit else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            guard let userID = userManager.currentUser?.id else {
                return
            }
            let user = UserDTO(id: userID, password: newPassword)
            try await userAPI.updateProfile(user: user) { result in
                switch result {
                    case .success(_):
                        showingSuccessAlert = true
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        isLoading = false
                }
            }
            
        }
    }
}

#Preview {
    NavigationView {
        ChangePasswordView()
            .environmentObject(UserManager.shared)
    }
} 
