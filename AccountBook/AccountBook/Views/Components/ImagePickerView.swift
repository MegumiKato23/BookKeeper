import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userAPI = UserAPI()
    @EnvironmentObject private var userManager: UserManager
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 预览区域
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    } else if let avatarURL = userManager.currentUser?.avatarURL,
                             let fileName = ImageManager.shared.getFileName(from: avatarURL),
                             let image = ImageManager.shared.getAvatar(fileName: fileName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 200, height: 200)
                    }
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 200, height: 200)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                
                // 错误信息
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // 选择图片按钮
                PhotosPicker(selection: $selectedItem,
                           matching: .images,
                           photoLibrary: .shared()) {
                    Label("选择照片", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("更换头像")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("保存") {
                    uploadAvatar()
                }
                .disabled(selectedImage == nil || isLoading)
            )
            .alert("更新成功", isPresented: $showingSuccessAlert) {
                Button("确定") { dismiss() }
            }
        }
        .onChange(of: selectedItem) { _, _ in
            loadSelectedImage()
        }
    }
    
    private func loadSelectedImage() {
        Task {
            guard let item = selectedItem else { return }
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            guard let image = UIImage(data: data) else { return }
            
            // 压缩图片
            guard let compressedData = image.jpegData(compressionQuality: 0.5) else { return }
            guard let compressedImage = UIImage(data: compressedData) else { return }
            
            await MainActor.run {
                selectedImage = compressedImage
            }
        }
    }
    
    private func uploadAvatar() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.5),
              let userID = userManager.currentUser?.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            try await userAPI.uploadAvatar(userID: userID, imageData: imageData) { result in
                switch result {
                    case .success(let user):
                        userManager.updateUser(user)
                        if let avatarURL = user.avatarURL, let fileName = ImageManager.shared.getFileName(from: avatarURL) {
                            do {
                                try ImageManager.shared.saveAvatar(image, fileName: fileName)
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                        showingSuccessAlert = true
                        isLoading = false
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        isLoading = false
                }
            }
        }
    }
}

#Preview {
    ImagePickerView()
        .environmentObject(UserManager.shared)
} 
