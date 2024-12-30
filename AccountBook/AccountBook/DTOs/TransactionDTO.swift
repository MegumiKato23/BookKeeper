import Foundation

struct TransactionDTO: Codable, Identifiable {
    var id: UUID?
    var type: TransactionType?
    var category: TransactionCategory?
    
    init(id: UUID? = nil, type: TransactionType? = nil, category: TransactionCategory? = nil) {
        self.id = id
        self.type = type
        self.category = category
    }
}
