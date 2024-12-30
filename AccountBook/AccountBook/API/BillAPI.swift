import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class BillAPI: ObservableObject {
    private let baseUrl = URL(string: "http://127.0.0.1:8080/api/bills")!
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    // MARK: - 获取所有账单
    func getAllBills() async throws -> [BillDTO] {
        let url = baseUrl
        let (data, _) = try await URLSession.shared.data(from: url)
        return try self.decoder.decode([BillDTO].self, from: data)
    }

    // MARK: - 获取账单
    func getBill(billID: UUID) async throws -> BillDTO {
        guard let url = URL(string: "\(baseUrl)/\(billID.uuidString)") else {
            throw APIError.invalidResponse
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try self.decoder.decode(BillDTO.self, from: data)
    }
    
    // MARK: - 更新账单
    func updateBill(bill: BillDTO, transactionID: UUID, completion: @escaping (Result<BillDTO, Error>) -> Void) async throws {
        guard let billID = bill.id, let url = URL(string: "\(baseUrl)/\(billID.uuidString)/\(transactionID.uuidString)") else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try self.encoder.encode(bill)
        
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
                let updatedBill = try self.decoder.decode(BillDTO.self, from: data)
                completion(.success(updatedBill))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - 删除账单
    func deleteBill(billID: UUID, completion: @escaping (Result<Bool, Error>) -> Void) async throws {
        guard let url = URL(string: "\(baseUrl)/\(billID.uuidString)") else {
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
    
    // MARK: - 获取用户账单
    func getUserBills(userID: UUID) async throws -> [BillDTO] {
        guard let url = URL(string: "\(baseUrl)/user/\(userID.uuidString)") else {
            throw APIError.invalidResponse
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // debug
//        // 打印服务器返回的原始数据和响应状态
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("服务器返回数据: \(jsonString)")
//        }
//        if let httpResponse = response as? HTTPURLResponse {
//            print("HTTP 状态码: \(httpResponse.statusCode)")
//        }
        
        do {
            return try self.decoder.decode([BillDTO].self, from: data)
        } catch {
            print("解码错误: \(error)")
            throw error
        }
    }
    
    // MARK: - 创建账单
    func createBill(bill: BillDTO, userID: UUID, transactionID: UUID, completion: @escaping (Result<Bool, Error>) -> Void) async throws {
        guard let url = URL(string: "\(baseUrl)/user/\(userID.uuidString)/transaction/\(transactionID.uuidString)") else {
            throw APIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try self.encoder.encode(bill)
        
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
    
    // MARK: - 获取用户的交易类型账单
    func getUserTransactionBills(userID: UUID, transactionID: UUID) async throws -> [BillDTO] {
        guard let url = URL(string: "\(baseUrl)/user/\(userID.uuidString)/transaction/\(transactionID.uuidString)") else {
            throw APIError.invalidResponse
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try self.decoder.decode([BillDTO].self, from: data)
    }
    
    // MARK: - 获取用户的收入账单
    func getUserIncomeBills(userID: UUID) async throws -> [BillDTO] {
        guard let url = URL(string: "\(baseUrl)/user/\(userID.uuidString)/income") else {
            throw APIError.invalidResponse
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try self.decoder.decode([BillDTO].self, from: data)
    }
    
    // MARK: - 获取用户的支出账单
    func getUserExpenseBills(userID: UUID) async throws -> [BillDTO] {
        guard let url = URL(string: "\(baseUrl)/user/\(userID.uuidString)/expense") else {
            throw APIError.invalidResponse
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try self.decoder.decode([BillDTO].self, from: data)
    }
    
    // MARK: - 获取用户指定月份的账单
    func getUserMonthlyBills(userID: UUID, year: Int, month: Int) async throws -> [BillDTO] {
        var urlComponents = URLComponents(url: baseUrl.appendingPathComponent("/user/\(userID.uuidString)/month"), resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "month", value: String(month))
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try MyJSONcoder.decoder.decode([BillDTO].self, from: data)
    }
    
    // MARK: - 获取用户指定年份的账单
    func getUserYearlyBills(userID: UUID, year: Int) async throws -> [BillDTO] {
        var urlComponents = URLComponents(url: baseUrl.appendingPathComponent("/user/\(userID.uuidString)/year"), resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "year", value: String(year))
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try MyJSONcoder.decoder.decode([BillDTO].self, from: data)
    }
    
    // 搜索账单
    func searchBills(userID: UUID, startDate: Date, endDate: Date) async throws -> [BillDTO] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 确保结束日期是当天的最后一刻
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        var urlComponents = URLComponents(url: baseUrl.appendingPathComponent("/user/\(userID.uuidString)/search"), resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "startDate", value: dateFormatter.string(from: startDate)),
            URLQueryItem(name: "endDate", value: dateFormatter.string(from: endOfDay))
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try MyJSONcoder.decoder.decode([BillDTO].self, from: data)
    }
}
