import Foundation
import UIKit

class ImageManager {
    static let shared = ImageManager()
    private let fileManager = FileManager.default
    
    private var avatarDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let avatarDirectory = documentsDirectory.appendingPathComponent("avatars")
        
        // 创建头像目录（如果不存在）
        if !fileManager.fileExists(atPath: avatarDirectory.path) {
            try? fileManager.createDirectory(at: avatarDirectory,
                                          withIntermediateDirectories: true)
        }
        
        return avatarDirectory
    }
    
    /// 保存头像图片
    func saveAvatar(_ image: UIImage, fileName: String) throws -> URL {
        // 确保图片数据有效
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ImageError.invalidImageData
        }
        
        // 创建文件URL
        let fileURL = avatarDirectory.appendingPathComponent(fileName)
        
        // 删除旧文件
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        
        // 保存新文件
        try imageData.write(to: fileURL)
        
        return fileURL
    }
    
    /// 获取头像图片
    func getAvatar(fileName: String) -> UIImage? {
        let fileURL = avatarDirectory.appendingPathComponent(fileName)
        guard let imageData = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: imageData)
    }
    
    /// 删除头像图片
    func deleteAvatar(fileName: String) {
        let fileURL = avatarDirectory.appendingPathComponent(fileName)
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// 从URL路径获取文件名
    func getFileName(from urlPath: String) -> String? {
        return urlPath.split(separator: "/").last.map(String.init)
    }
}

enum ImageError: Error {
    case invalidImageData
} 
