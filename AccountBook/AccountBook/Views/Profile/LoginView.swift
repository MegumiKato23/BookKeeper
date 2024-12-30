import SwiftUI

struct LoginView: View {
    @StateObject private var userAPI = UserAPI()
    @EnvironmentObject private var userManager: UserManager
    
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingRegistration = false
    @State private var showingForgotPassword = false
    
    private var isValidInput: Bool {
        phoneNumber.count == 11 && !password.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Logo和标题
                    VStack(spacing: 15) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("记账本")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    
                    // 错误信息
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    
                    // 登录表单
                    VStack(spacing: 20) {
                        // 手机号输入框
                        HStack {
                            Image(systemName: "phone")
                                .foregroundColor(.gray)
                            TextField("手机号", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .textContentType(.telephoneNumber)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // 密码输入框
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("密码", text: $password)
                                .textContentType(.password)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // 忘记密码按钮
                        HStack {
                            Spacer()
                            Button("忘记密码？") {
                                showingForgotPassword = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 登录按钮
                    Button(action: login) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text("登录")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isValidInput ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!isValidInput || isLoading)
                    .padding(.horizontal)
                    
                    // 注册入口
                    HStack(spacing: 5) {
                        Text("还没有账号？")
                            .foregroundColor(.secondary)
                        Button("立即注册") {
                            showingRegistration = true
                        }
                        .foregroundColor(.blue)
                    }
                    .font(.subheadline)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingRegistration) {
            RegisterView()
        }
        .sheet(isPresented: $showingForgotPassword) {
            // TODO:
//            ForgotPasswordView()
        }
    }
    
    private func login() {
        // 隐藏键盘
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
        
        isLoading = true
        errorMessage = nil
        
        // 验证手机号格式
        guard phoneNumber.count == 11 else {
            errorMessage = "请输入正确的手机号"
            isLoading = false
            return
        }
        
        Task { @MainActor in
            try await userAPI.login(phoneNumber: phoneNumber, password: password) { result in
                switch result {
                    case .success(let user):
                        withAnimation {
                            userManager.login(user: user)
                        }
                        isLoading = false
                    case .failure(let error):
                        errorMessage = "登录失败：\(error.localizedDescription)"
                        isLoading = false
                }
            }            
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserManager.shared)
}
