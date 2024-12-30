import SwiftUI

struct ChangeUsernameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: UserManager
    @StateObject private var userAPI = UserAPI()
    @State private var newUsername: String = ""
    @State private var showingSuccessAlert = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        Form {
            Section {
                TextField("新用户名", text: $newUsername)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            } footer: {
                Text("用户名长度需在2-20个字符之间")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("修改用户名")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    Task {
                        await saveUsername()
                    }
                }
                .disabled(newUsername.isEmpty || isLoading || !isValidUsername(newUsername))
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
        .alert("用户名修改成功", isPresented: $showingSuccessAlert) {
            Button("确定", role: .cancel) {
                dismiss()
            }
        }
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2 && trimmed.count <= 20
    }
    
    private func saveUsername() async {
        guard let userID = userManager.currentUser?.id else { return }
        guard isValidUsername(newUsername) else {
            errorMessage = "用户名长度需在2-20个字符之间"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            let user = UserDTO(id: userID, name: newUsername)
            try await userAPI.updateProfile(user: user) { result in
                switch result {
                    case .success(let user):
                        showingSuccessAlert = true
                        userManager.updateUser(user)
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
        ChangeUsernameView()
            .environmentObject(UserManager.shared)
    }
} 
