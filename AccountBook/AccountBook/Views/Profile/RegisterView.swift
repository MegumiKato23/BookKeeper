import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userAPI = UserAPI()
	@StateObject private var accountAPI = AccountAPI()
    
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
//    @State private var verificationCode: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSuccessAlert = false
    @State private var countdown: Int = 0
    
    private var canSendCode: Bool {
        phoneNumber.count == 11 && countdown == 0
    }
    
    private var canRegister: Bool {
        !name.isEmpty &&
        phoneNumber.count == 11 &&
        password.count >= 6 &&
        password == confirmPassword
//        verificationCode.count == 6
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // 错误信息
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }
                    
                    // 注册表单
                    VStack(spacing: 20) {
                        // 用户名
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.gray)
                            TextField("用户名", text: $name)
                                .textContentType(.username)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // 手机号
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
                        
                        
                        // 密码
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("密码（不少于6位）", text: $password)
                                .textContentType(.newPassword)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // 确认密码
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("确认密码", text: $confirmPassword)
                                .textContentType(.newPassword)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // 注册按钮
                    Button(action: register) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text("注册")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(canRegister ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!canRegister || isLoading)
                    .padding(.horizontal)
                    
                    // 用户协议
                    VStack(spacing: 8) {
                        Text("注册即代表同意")
                            .foregroundColor(.secondary) +
                        Text("《用户协议》")
                            .foregroundColor(.blue) +
                        Text("和")
                            .foregroundColor(.secondary) +
                        Text("《隐私政策》")
                            .foregroundColor(.blue)
                    }
                    .font(.footnote)
                }
                .padding(.vertical, 30)
            }
            .navigationTitle("注册")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("取消") { dismiss() })
            .alert("注册成功", isPresented: $showingSuccessAlert) {
                Button("确定") { dismiss() }
            }
            .onDisappear {
                // 停止倒计时
                countdown = 0
            }
        }
    }
    
    
    private func register() {
        // 隐藏键盘
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
        
        // 验证输入
        guard !name.isEmpty else {
            errorMessage = "请输入用户名"
            return
        }
        
        guard phoneNumber.count == 11 else {
            errorMessage = "请输入正确的手机号"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "密码不能少于6位"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "两次输入的密码不一致"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            let user = UserDTO(name: name, password: password, phoneNumber: phoneNumber)
			var userID: UUID?
            try await userAPI.register(user: user) { result in
                switch result {
                    case .success(let user):
						userID = user.id
                    case .failure(let error):
                        errorMessage = "注册失败：\(error.localizedDescription)"
                        isLoading = false
                }
            }
			
			guard let userID = userID else {
				return
			}
			try await accountAPI.createAccount(userID: userID) { result in
				switch result {
					case .success(_):
						showingSuccessAlert = true
					case .failure(let error):
						errorMessage = "注册失败：\(error.localizedDescription)"
						isLoading = false
				}
			}
        }
    }
}

#Preview {
    RegisterView()
} 
