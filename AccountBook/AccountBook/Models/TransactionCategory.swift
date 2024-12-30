import Foundation

/// 交易类别枚举
enum TransactionCategory: String, Codable, CaseIterable {
    // 支出类别
    case food = "餐饮"
    case shopping = "购物"
    case transport = "交通"
    case entertainment = "娱乐"
    case housing = "居住"
    case medical = "医疗"
    case education = "教育"
    case other = "其他"
    
    // 收入类别
    case salary = "工资"
    case bonus = "奖金"
    case investment = "投资"
    case partTime = "兼职"
    case gift = "礼金"
    case otherIncome = "其他收入"
    
    /// 获取支出类别
    static var expenseCategories: [TransactionCategory] {
        [.food, .shopping, .transport, .entertainment, .housing, .medical, .education, .other]
    }
    
    /// 获取收入类别
    static var incomeCategories: [TransactionCategory] {
        [.salary, .bonus, .investment, .partTime, .gift, .otherIncome]
    }
    
    // 获取类别图标
    var iconName: String {
        switch self {
            case .food: return "fork.knife"
            case .shopping: return "cart"
            case .transport: return "car"
            case .entertainment: return "gamecontroller"
            case .medical: return "cross.case"
            case .education: return "book"
            case .housing: return "house"
            case .other: return "ellipsis.circle"
            case .salary: return "dollarsign.circle"
            case .bonus: return "gift"
            case .investment: return "chart.line.uptrend.xyaxis"
            case .partTime: return "briefcase"
            case .gift: return "gift.circle"
            case .otherIncome: return "plus.circle"
        }
    }
    
    // 获取类别颜色
    var colorName: String {
        switch self {
            case .food: return "orange"
            case .shopping: return "oxblood"
            case .transport: return "bubblegum"
            case .entertainment: return "purple"
            case .medical: return "buttercup"
            case .education: return "lavender"
            case .housing: return "teal"
            case .other: return "seafoam"
            case .salary: return "yellow"
            case .bonus: return "teal"
            case .investment: return "magenta"
            case .partTime: return "orange"
            case .gift: return "periwinkle"
            case .otherIncome: return "poppy"
        }
    }
}
