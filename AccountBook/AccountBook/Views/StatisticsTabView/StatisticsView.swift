import SwiftUI
import Charts

struct StatisticsView: View {
    let type: TransactionType
    let bills: [BillDTO]
    @Environment(\.dismiss) private var dismiss
    
    private var filteredBills: [BillDTO] {
        bills.filter { $0.transaction?.type == type }
    }
    
    private var categoryData: [(TransactionCategory, Double)] {
        var data: [TransactionCategory: Double] = [:]
        
        for bill in filteredBills {
            if let category = bill.transaction?.category {
                data[category, default: 0] += bill.amount
            }
        }
        
        return data.sorted { $0.value > $1.value }
    }
    
    private var totalAmount: Double {
        categoryData.reduce(0) { $0 + $1.1 }
    }
    
    var body: some View {
        NavigationView {
            List {
                if categoryData.isEmpty {
                    EmptyDataView()
                } else {
                    // 饼图部分
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("总\(type.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("¥\(String(format: "%.2f", totalAmount))")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(type == .expense ? .red : .green)
                            
                            Chart {
                                ForEach(categoryData, id: \.0) { category, amount in
                                    SectorMark(
                                        angle: .value("Amount", amount),
                                        innerRadius: .ratio(0.618),
                                        angularInset: 1.5
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(Color(category.colorName))
                                }
                            }
                            .frame(height: 200)
                        }
                        .padding()
                        .listRowInsets(EdgeInsets())
                    }
                    
                    // 类别明细
                    Section {
                        ForEach(categoryData, id: \.0) { category, amount in
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color(category.colorName))
                                    .cornerRadius(8)
                                
                                Text(category.rawValue)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("¥\(String(format: "%.2f", amount))")
                                        .font(.headline)
                                    
                                    Text("\(Int(amount / totalAmount * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("\(type.rawValue)统计")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("完成") { dismiss() })
        }
    }
}

struct EmptyDataView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("暂无数据")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    StatisticsView(
        type: .expense,
        bills: [
            BillDTO(
                id: UUID(),
                transaction: TransactionDTO(
                    id: UUID(),
                    type: .expense,
                    category: .food
                ),
                amount: 100,
                date: Date()
            ),
            BillDTO(
                id: UUID(),
                transaction: TransactionDTO(
                    id: UUID(),
                    type: .expense,
                    category: .shopping
                ),
                amount: 200,
                date: Date()
            ),
            BillDTO(
                id: UUID(),
                transaction: TransactionDTO(
                    id: UUID(),
                    type: .expense,
                    category: .transport
                ),
                amount: 150,
                date: Date()
            )
        ]
    )
} 
