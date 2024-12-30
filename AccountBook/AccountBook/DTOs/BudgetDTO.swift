import Foundation

/// 预算模型
struct BudgetDTO: Codable, Identifiable {
    var id: UUID?
    var user: UserDTO?
    var budget: Double
    var description: String?
    var type: BudgetType?

    init(id: UUID? = nil, user: UserDTO? = nil, budget: Double, description: String? = nil, type: BudgetType? = nil) {
        self.id = id
        self.user = user
        self.budget = budget
        self.description = description
        self.type = type
    }
}
enum BudgetType: String, Codable {
    case year = "年预算"
    case month = "月预算"
}

