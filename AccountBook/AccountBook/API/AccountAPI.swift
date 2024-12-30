import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class AccountAPI: ObservableObject {
    private let baseUrl = URL(string: "http://127.0.0.1:8080/api/accounts")!
    
    // MARK: - 创建账户
    func createAccount(userID: UUID, completion: @escaping (Result<Bool, Error>) -> Void) async throws {
        guard let url = URL(string: "\(baseUrl)/\(userID.uuidString)") else {
            throw APIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
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
            completion(.success(true))
        }.resume()
    }
    
    // MARK: - 获取用户账户
    func getAccount(userID: UUID) async throws -> AccountDTO {
        guard let url = URL(string: "\(baseUrl)/\(userID.uuidString)") else {
            throw APIError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(AccountDTO.self, from: data)
    }
    
    // MARK: - 获取用户指定月份的收支
    func getMonthlyBalance(userID: UUID, year: Int, month: Int) async throws -> BalanceResponse {
        var urlComponents = URLComponents(url: baseUrl.appendingPathComponent("/\(userID.uuidString)/balance/month"), resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "month", value: String(month))
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try MyJSONcoder.decoder.decode(BalanceResponse.self, from: data)
    }
	
	// MARK: - 获取用户指定年份的收支
	func getYearlyBalance(userID: UUID, year: Int) async throws -> BalanceResponse {
		var urlComponents = URLComponents(url: baseUrl.appendingPathComponent("/\(userID.uuidString)/balance/year"), resolvingAgainstBaseURL: true)!
		urlComponents.queryItems = [
			URLQueryItem(name: "year", value: String(year))
		]
		
		guard let url = urlComponents.url else {
			throw URLError(.badURL)
		}
		
		let (data, _) = try await URLSession.shared.data(from: url)
		return try MyJSONcoder.decoder.decode(BalanceResponse.self, from: data)
	}
    
    // MARK: - 删除账户
    func deleteAccount(userID: UUID, completion: @escaping (Result<Bool, Error>) -> Void) async throws {
        guard let url = URL(string: "\(baseUrl)/\(userID.uuidString)") else {
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
}

// MARK: - 余额响应模型
struct BalanceResponse: Codable {
    let totalIncome: Double
    let totalExpense: Double
    let balance: Double
    let startDate: Date
    let endDate: Date
    let bills: [BillDTO]
}
