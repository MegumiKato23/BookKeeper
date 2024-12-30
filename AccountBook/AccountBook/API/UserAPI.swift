import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class UserAPI: ObservableObject {
    private let baseUrl = URL(string: "http://127.0.0.1:8080/api/users")!
    
    @Published var currentUser: UserDTO?
    @Published var isAuthenticated = false
    
    // MARK: - 用户注册
	func register(user: UserDTO, completion: @escaping (Result<UserResponse, Error>) -> Void) async throws {
        let url = baseUrl.appendingPathComponent("/register")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(user)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(APIError.invalidResponse))
                return
            }
			guard let data = data else {
				completion(.failure(APIError.invalidResponse))
				return
			}
			do {
				let user = try JSONDecoder().decode(UserResponse.self, from: data)
				completion(.success(user))
			} catch {
				completion(.failure(error))
			}
        }.resume()
    }
    
    // MARK: - 用户登录
    func login(phoneNumber: String, password: String, completion: @escaping (Result<UserResponse, Error>) -> Void) async throws {
        let url = baseUrl.appendingPathComponent("/login")
        
        let loginData = ["phoneNumber": phoneNumber, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(loginData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            guard let data = data else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            do {
                let user = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - 获取用户资料
    func getProfile(userID: UUID) async throws -> UserDTO {
        guard let url = URL(string: "\(baseUrl)/\(userID.uuidString)/profile") else {
            throw APIError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(UserDTO.self, from: data)
    }
    
    // MARK: - 更新用户资料
    func updateProfile(user: UserDTO, completion: @escaping (Result<UserResponse, Error>) -> Void) async throws {
        guard let userID = user.id, let url = URL(string: "\(baseUrl)/\(userID.uuidString)/profile") else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(user)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            guard let data = data else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            do {
                let updatedUser = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(updatedUser))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - 删除用户
    func deleteUser(userID: UUID, completion: @escaping (Result<Bool, Error>) -> Void) async throws {
        guard let url = URL(string: "\(baseUrl)/\(userID.uuidString)/profile") else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 204 else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            completion(.success(true))
        }.resume()
    }
    
    // MARK: - 上传头像
    func uploadAvatar(userID: UUID, imageData: Data, completion: @escaping (Result<UserResponse, Error>) -> Void) async throws {
        guard let url = URL(string: "\(baseUrl)/\(userID.uuidString)/avatar") else {
            throw APIError.invalidResponse
        }
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 构建multipart表单数据
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            guard let data = data else {
                completion(.failure(APIError.invalidResponse))
                return
            }   
            do {
                let updatedUser = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(updatedUser))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Data 扩展
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// MARK: - User 辅助
struct UserResponse: Codable {
    let id: UUID?
    let name: String?
    let phoneNumber: String?
    let avatarURL: String?
    
    init(id: UUID? = nil, name: String? = nil, phoneNumber: String? = nil, avatarURL: String? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.avatarURL = avatarURL
    }
}
