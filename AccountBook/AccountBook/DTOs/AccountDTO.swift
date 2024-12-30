import Foundation

struct AccountDTO: Codable, Identifiable {
    var id: UUID?
    var user: UserDTO?
    var balance: Double
    
    init(id: UUID? = nil, user: UserDTO? = nil, balance: Double) {
        self.id = id
        self.user = user
        self.balance = balance
    }
}
