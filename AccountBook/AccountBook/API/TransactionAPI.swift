import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class TransactionAPI: ObservableObject {
    private let baseUrl = URL(string: "http://127.0.0.1:8080/api/transactions")!
    
    // MARK: - 获取所有交易类型
    func getTransactions() async throws -> [TransactionDTO] {
        let url = baseUrl
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([TransactionDTO].self, from: data)
    }
    
    // MARK: - 获取支出类型
    func getExpenseCategories() async throws -> [String] {
        let url = baseUrl.appendingPathComponent("/expense")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([String].self, from: data)
    }

    // MARK: - 获取收入类型
    func getIncomeCategories() async throws -> [String] {
        let url = baseUrl.appendingPathComponent("/income")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([String].self, from: data)
    }

    // MARK: - 获取类型id
    func getCategoryId(category: String) async throws -> TransactionDTO {
        var urlComponents = URLComponents(url: baseUrl.appendingPathComponent("/types"), resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "category", value: category)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(TransactionDTO.self, from: data)
    }
}
