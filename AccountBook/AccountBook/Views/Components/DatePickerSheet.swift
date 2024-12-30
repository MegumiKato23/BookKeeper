import SwiftUI

struct DatePickerSheet: View {
    @Binding var date: Date
    @Environment(\.dismiss) private var dismiss

    // 年份范围：前5年到后5年
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear-5)...(currentYear+5))
    }()

    // 月份范围：1-12
    private let months = Array(1...12)

    // 日期范围：1-31（根据年月动态计算）
    private func daysInMonth(year: Int, month: Int) -> Int {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }

    // 当前选中的年、月、日
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    @State private var selectedDay: Int

    init(date: Binding<Date>) {
        self._date = date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date.wrappedValue)
        _selectedYear = State(initialValue: components.year!)
        _selectedMonth = State(initialValue: components.month!)
        _selectedDay = State(initialValue: components.day!)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Button("取消") { dismiss() }
                Spacer()
                Text("选择日期")
                    .font(.headline)
                Spacer()
                Button("确定") {
                    updateDate()
                    dismiss()
                }
            }
            .padding()

            // 选择器
            HStack(spacing: 15) {
                // 年份选择器
                Picker("年", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(format: "%d年", year))
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 110)
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

                // 日期选择器
                Picker("日", selection: $selectedDay) {
                    ForEach(1...daysInMonth(year: selectedYear, month: selectedMonth), id: \.self) { day in
                        Text("\(day)日")
                            .tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
                .clipped()
            }
            .padding(.horizontal)
        }
        .background(Color(.systemBackground))
        .onChange(of: selectedYear) { oldValue, newValue in 
//            print("年份变化: \(oldValue) -> \(newValue)")
            validateDay()
        }
        .onChange(of: selectedMonth) { oldValue, newValue in
//            print("月份变化: \(oldValue) -> \(newValue)")
            validateDay()
        }
//        .onChange(of: selectedDay) { oldValue, newValue in
//            print("日期变化: \(oldValue) -> \(newValue)")
//            let dateString = "\(selectedYear)年\(selectedMonth)月\(selectedDay)日"
//            print("当前选择日期: \(dateString)")
//        }
    }

    // 验证并调整日期
    private func validateDay() {
        let maxDay = daysInMonth(year: selectedYear, month: selectedMonth)
        if selectedDay > maxDay {
            selectedDay = maxDay
        }
    }

    // 更新日期
    private func updateDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = selectedDay
		components.hour = 12
		components.minute = 0
		components.second = 0
		// 指定时区为当前时区
		components.timeZone = Calendar.current.timeZone
		
        if let newDate = Calendar.current.date(from: components) {
            date = newDate
        }
    }
}
#Preview {
    DatePickerSheet(date: .constant(Date()))
} 
