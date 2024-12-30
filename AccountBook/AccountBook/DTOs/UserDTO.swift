import Foundation

struct UserDTO: Codable, Identifiable {
    // 基本信息
    var id: UUID?
    var name: String?
    var password: String?
    var phoneNumber: String?
    var avatarURL: String?

    // 创建时间
    var createdAt: Date?
    var updatedAt: Date?
    
    init(id: UUID? = nil, name: String? = nil, password: String? = nil, phoneNumber: String? = nil, avatarURL: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.password = password
        self.phoneNumber = phoneNumber
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
