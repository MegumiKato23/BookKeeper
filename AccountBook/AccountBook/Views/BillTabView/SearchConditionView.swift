import SwiftUI

struct SearchConditionView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var selectedType: TransactionType?
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var searchText: String
    @Binding var showingStartDatePicker: Bool
    @Binding var showingEndDatePicker: Bool
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy年MM月dd日"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 类型选择
            CustomSegmentedControl(
                selection: $selectedType,
                items: [
                    ("全部", nil),
                    ("支出", TransactionType.expense),
                    ("收入", TransactionType.income)
                ],
                accentColor: themeManager.accentColor.color
            )
            .padding(.horizontal)
            
            // 日期选择
            HStack(spacing: 8) {
                Button(action: { showingStartDatePicker = true }) {
                    HStack {
                        Text("从")
                            .foregroundColor(.secondary)
                        Text(dateFormatter.string(from: startDate))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Text("至")
                    .foregroundColor(.secondary)
                
                Button(action: { showingEndDatePicker = true }) {
                    Text(dateFormatter.string(from: endDate))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.accentColor.color)
                TextField("搜索类型、备注或金额", text: $searchText)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
}
