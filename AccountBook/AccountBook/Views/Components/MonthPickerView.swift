import SwiftUI

struct MonthPickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    // 年份范围：前5年到后5年
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear-5)...(currentYear+5))
    }()
    
    // 月份范围：1-12
    private let months = Array(1...12)
    
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate.wrappedValue)
        let month = calendar.component(.month, from: selectedDate.wrappedValue)
        _selectedYear = State(initialValue: year)
        _selectedMonth = State(initialValue: month)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 选择器
                HStack(spacing: 15) {
                    // 年份选择器
                    Picker("年", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(year)年")
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 120)
                    .clipped()
                    
                    // 月份选择器
                    Picker("月", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text("\(month)月")
                                .tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80)
                    .clipped()
                }
                .padding()
            }
            .navigationTitle("选择月份")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("确定") {
                    updateSelectedDate()
                    dismiss()
                }
            )
        }
    }
    
    private func updateSelectedDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            selectedDate = date
        }
    }
}

#Preview {
    MonthPickerView(selectedDate: .constant(Date()))
} 
