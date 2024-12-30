import SwiftUI

struct BillDetailView: View {
    @Binding var bill: BillDTO
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    
    private var amountColor: Color {
        bill.transaction?.type == .expense ? .red : .green
    }
    
    private var amountPrefix: String {
        bill.transaction?.type == .expense ? "-" : "+"
    }
    
    var body: some View {
        List {
            // 金额部分
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("\(amountPrefix)¥\(String(format: "%.2f", bill.amount))")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(amountColor)
                        
                        Text(bill.transaction?.type?.rawValue ?? "未知类型")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 20)
            }
            
            // 详细信息
            Section {
                DetailRow(title: "类别",
                         icon: bill.transaction?.category?.iconName ?? "questionmark.circle",
                         iconColor: Color(bill.transaction?.category?.colorName ?? "gray")) {
                    Text(bill.transaction?.category?.rawValue ?? "未分类")
                }
                
                DetailRow(title: "日期",
                         icon: "calendar",
                         iconColor: .blue) {
                    Text("\(Calendar.current.component(.year, from: bill.date))年\(Calendar.current.component(.month, from: bill.date))月\(Calendar.current.component(.day, from: bill.date))日")
                }
                
                if let description = bill.description {
                    DetailRow(title: "备注",
                             icon: "note.text",
                             iconColor: .orange) {
                        Text(description)
                    }
                }
            }
            
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("编辑") {
            showingEditSheet = true
        })
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                EditBillView(bill: $bill)
            }
        }
    }
}

struct DetailRow<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: () -> Content
    
    var body: some View {
        HStack {
            Label {
                Text(title)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            Spacer()
            content()
        }
    }
}

#Preview {
    @Previewable @State var bill = BillDTO(
        id: UUID(),
        transaction: TransactionDTO(
            id: UUID(),
            type: .expense,
            category: .food
        ),
        amount: 99.9,
        date: Date(),
        description: "午餐"
    )
    NavigationView {
        BillDetailView(bill: $bill)
    }
} 
