import SwiftUI

struct BillRowView: View {
    let bill: BillDTO
    
    private var amountColor: Color {
        bill.transaction?.type == .expense ? .red : .green
    }
    
    private var amountPrefix: String {
        bill.transaction?.type == .expense ? "-" : "+"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 类别图标
            Image(systemName: bill.transaction?.category?.iconName ?? "questionmark.circle")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color(bill.transaction?.category?.colorName ?? "gray"))
                .cornerRadius(8)
            
            // 类别和备注
            VStack(alignment: .leading, spacing: 4) {
                Text(bill.transaction?.category?.rawValue ?? "未分类")
                    .font(.headline)
                
                if let description = bill.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 金额和时间
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(amountPrefix)¥\(String(format: "%.2f", bill.amount))")
                    .font(.headline)
                    .foregroundColor(amountColor)
                
                Text("\(Calendar.current.component(.year, from: bill.date))年\(Calendar.current.component(.month, from: bill.date))月\(Calendar.current.component(.day, from: bill.date))日")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    BillRowView(bill: BillDTO(
        id: UUID(),
        transaction: TransactionDTO(
            id: UUID(),
            type: .expense,
            category: .food
        ),
        amount: 99.9,
        date: Date(),
        description: "午餐"
    ))
    .previewLayout(.sizeThatFits)
    .padding()
} 
