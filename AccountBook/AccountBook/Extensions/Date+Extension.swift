import Foundation

extension Date {
    var chineseStyleString: String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        return "\(year)年\(month)月\(day)日"
    }
} 