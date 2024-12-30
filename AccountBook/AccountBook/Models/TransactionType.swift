import Foundation

/// 交易类型枚举
enum TransactionType: String, Codable {
    case expense = "支出"
    case income = "收入"
}
