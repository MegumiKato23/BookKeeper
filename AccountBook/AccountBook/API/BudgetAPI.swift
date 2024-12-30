import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class BudgetAPI: ObservableObject {
    private let baseUrl = URL(string: "http://127.0.0.1:8080/api/budgets")!
    
    // MARK: - 获取用户预算
    func getBudget(type: String, userID: UUID) async throws -> BudgetDTO {
        guard let url = URL(string: "\(baseUrl)/\(userID.uuidString)") else {
            throw APIError.invalidResponse
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: type)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(BudgetDTO.self, from: data)
    }
    
    // MARK: - 更新用户预算
    func updateBudget(userID: UUID, budget: BudgetDTO, completion: @escaping (Result<BudgetDTO, Error>) -> Void) async throws {
        guard let url = URL(string: "\(baseUrl)/\(userID.uuidString)") else {
            throw APIError.invalidResponse
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: budget.type?.rawValue)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(budget)
        
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
                let updatedBudget = try JSONDecoder().decode(BudgetDTO.self, from: data)
                completion(.success(updatedBudget))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - 创建预算
    func createBudget(userID: UUID, budget: BudgetDTO, completion: @escaping (Result<Bool, Error>) -> Void) async throws {
        guard let url = URL(string: "\(baseUrl)/\(userID.uuidString)") else {
            throw APIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(budget)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 201 else {
                completion(.failure(APIError.invalidResponse))
                return
            }
        }.resume()
    }
    
    // MARK: - 删除预算
    func deleteBudget(type: String, userID: UUID, completion: @escaping (Result<Bool, Error>) -> Void) async throws {
        guard let url = URL(string: "\(baseUrl)/\(userID.uuidString)") else {
            throw APIError.invalidResponse
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: type)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
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
}
