import SwiftUI

// 年份选择器视图
struct YearPickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear-5)...(currentYear+5))
    }()
    
    @State private var selectedYear: Int
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        let year = Calendar.current.component(.year, from: selectedDate.wrappedValue)
        _selectedYear = State(initialValue: year)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("年", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text("\(year)年")
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("选择年份")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("确定") {
                    var components = DateComponents()
                    components.year = selectedYear
                    components.month = 1
                    components.day = 1
                    if let date = Calendar.current.date(from: components) {
                        selectedDate = date
                    }
                    dismiss()
                }
            )
        }
    }
}
