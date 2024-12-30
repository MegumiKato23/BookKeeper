import Foundation

struct BillDTO: Codable, Identifiable {
    var id: UUID?
    var transaction: TransactionDTO?
    var user: UserDTO?
    var amount: Double
    var date: Date
    var description: String?
    
    init(id: UUID? = nil, transaction: TransactionDTO? = nil, user: UserDTO? = nil, amount: Double, date: Date, description: String? = nil) {
        self.id = id
        self.transaction = transaction
        self.user = user
        self.amount = amount
        self.date = date
        self.description = description
    }
}
