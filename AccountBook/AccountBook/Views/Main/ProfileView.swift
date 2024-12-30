import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userManager: UserManager
	@EnvironmentObject private var themeManager: ThemeManager
	@StateObject private var accountAPI = AccountAPI()
    @State private var showingLogoutAlert = false
    @State private var showingImagePicker = false
    @State private var avatarUpdateCounter = 0  // 添加计数器用于强制刷新
	@State private var userBalance: Double = 0
	
    var body: some View {
        List {
            // 用户基本信息
            Section {
                HStack(spacing: 15) {
                    // 头像
                    Button(action: { showingImagePicker = true }) {
                        if let avatarURL = userManager.currentUser?.avatarURL,
                           let fileName = ImageManager.shared.getFileName(from: avatarURL),
                           let image = ImageManager.shared.getAvatar(fileName: fileName) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        }
                    }
                    .id(avatarUpdateCounter)  // 使用计数器强制刷新头像
                    
                    // 用户名和手机号
                    VStack(alignment: .leading, spacing: 5) {
                        Text(userManager.currentUser?.name ?? "未知用户")
                            .font(.headline)
                        
                        Text(userManager.currentUser?.phoneNumber ?? "未绑定手机")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
			// 钱包卡片
			Section {
				NavigationLink {
					BudgetDetailView()
				} label: {
					HStack(spacing: 20) {
						// 钱包图标
						Image(systemName: "wallet.pass.fill")
							.font(.system(size: 48))
							.foregroundStyle(themeManager.accentColor.color)
						
						// 余额信息
						VStack(alignment: .leading, spacing: 8) {
							Text("账户余额")
								.font(.subheadline)
								.foregroundColor(.secondary)
							Text("¥ \(String(format: "%.2f", userBalance))")
								.font(.system(size: 28, weight: .medium))
								.foregroundColor(.primary)
						}
						
						Spacer()
					}
					.padding(.vertical, 8)
				}
			}
			
            // 账户安全
            Section {
                NavigationLink {
                    ChangeUsernameView()
                } label: {
                    Label("修改用户名", systemImage: "pencil.and.outline")
                }
                
                NavigationLink {
                    ChangePasswordView()
                } label: {
                    Label("修改密码", systemImage: "lock")
                }
            } header: {
                Text("账户安全")
            }
            
            // 通用设置
            Section {
                NavigationLink {
                    ThemeSettingView()
                } label: {
                    Label("主题设置", systemImage: "paintpalette")
                }
                
                NavigationLink {
                    NotificationSettingView()
                } label: {
                    Label("通知设置", systemImage: "bell")
                }
            } header: {
                Text("通用设置")
            }
            
            // 关于
            Section {
                NavigationLink {
                    AboutView()
                } label: {
                    Label("关于我们", systemImage: "info.circle")
                }
            }
            
            // 退出登录
            Section {
                Button(role: .destructive) {
                    showingLogoutAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("退出登录")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("我的")
        .alert("确认退出", isPresented: $showingLogoutAlert) {
            Button("取消", role: .cancel) {}
            Button("退出", role: .destructive) {
                // 退出登录时清除头像缓存
                if let avatarURL = userManager.currentUser?.avatarURL,
                   let fileName = ImageManager.shared.getFileName(from: avatarURL) {
                    ImageManager.shared.deleteAvatar(fileName: fileName)
                }
                userManager.logout()
            }
        } message: {
            Text("确定要退出登录吗？")
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView()
        }
        .onChange(of: showingImagePicker) { _, isShowing in
            if !isShowing {
                // 图片选择器关闭时，增加计数器值来触发视图刷新
                avatarUpdateCounter += 1
            }
        }
		.task {
			getBalance()
		}
    }
	
	private func getBalance() {
		guard let userID = userManager.currentUser?.id else {
			return
		}
		
		Task {
			let account = try await accountAPI.getAccount(userID: userID)
			userBalance = account.balance
		}
	}
}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(UserManager.shared)
			.environmentObject(ThemeManager.shared)
    }
} 
