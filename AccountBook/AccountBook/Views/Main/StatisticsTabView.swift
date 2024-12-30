import SwiftUI

struct StatisticsTabView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var billAPI = BillAPI()
    @StateObject private var accountAPI = AccountAPI()
    
    @State private var selectedType: TransactionType = .expense
    @State private var selectedTimeRange: TimeRange = .month
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var bills: [BillDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedCategory: TransactionCategory?
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = selectedTimeRange == .month ? "yyyy年MM月" : "yyyy年"
        return formatter
    }
    
    // 按类别统计数据
    private var categoryData: [(TransactionCategory, Double)] {
        var data: [TransactionCategory: Double] = [:]
        
        for bill in bills where bill.transaction?.type == selectedType {
            if let category = bill.transaction?.category {
                data[category, default: 0] += bill.amount
            }
        }
        
        return data.sorted { $0.value > $1.value }
    }
    
    private var timeSeriesData: [(Date, Double)] {
        var data: [(Date, Double)] = []
        let calendar = Calendar.current
        
        if selectedTimeRange == .month {
            let yearMonth = calendar.dateComponents([.year, .month], from: selectedDate)
            guard let firstDayOfMonth = calendar.date(from: yearMonth) else { return [] }
            
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth) else { return [] }
            // 获取这个月的天数
            let numberOfDays = calendar.dateComponents([.day], from: firstDayOfMonth, to: nextMonth).day ?? 0
            
            // 生成这个月每一天的数据点
            for day in 1...numberOfDays {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                    data.append((date, 0.0))
                }
            }
            
            // 更新账单数据
            for bill in bills where bill.transaction?.type == selectedType {
                let billDate = calendar.startOfDay(for: bill.date)
                if let index = data.firstIndex(where: { calendar.isDate($0.0, inSameDayAs: billDate) }) {
                    data[index].1 += bill.amount
                }
            }
        } else {
            // 年视图：显示选中年份的每个月
            let year = calendar.component(.year, from: selectedDate)
            
            // 生成这一年每个月的数据点
            for month in 1...12 {
                var components = DateComponents()
                components.year = year
                components.month = month
                components.day = 1
                if let date = calendar.date(from: components) {
                    data.append((date, 0.0))
                }
            }
            
            // 更新账单数据
            for bill in bills where bill.transaction?.type == selectedType {
                let billComponents = calendar.dateComponents([.year, .month], from: bill.date)
                if let index = data.firstIndex(where: {
                    let components = calendar.dateComponents([.year, .month], from: $0.0)
                    return components.year == billComponents.year &&
                    components.month == billComponents.month
                }) {
                    data[index].1 += bill.amount
                }
            }
        }
        
        return data
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 类型切换
				CustomSegmentedControl(selection: $selectedType,
									   items: [
										("支出", TransactionType.expense),
										("收入", TransactionType.income)
									   ],
									  accentColor: themeManager.accentColor.color)
					.padding(.horizontal)
                
                // 时间范围选择
                HStack {
                    // 时间维度切换
					CustomSegmentedControl(
											selection: $selectedTimeRange,
											items: [
												("月", TimeRange.month),
												("年", TimeRange.year)
											],
											accentColor: themeManager.accentColor.color,
											width: 120
										)
                    
                    Spacer()
                    
                    // 日期选择
                    Button(action: { showingDatePicker = true }) {
                        HStack {
                            Text(dateFormatter.string(from: selectedDate))
                            Image(systemName: "chevron.down")
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                
                // 图表
                ChartView(data: timeSeriesData, timeRange: selectedTimeRange)
                    .padding()
                
                // 类别排行榜
                if bills.isEmpty {
                    EmptyBillView()
                        .scaledToFill()
                }
                else if selectedCategory == nil {
                    // 显示所有类别
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(categoryData.prefix(6), id: \.0) { category, amount in
                            CategoryCard(
                                category: category,
                                amount: amount,
                                total: categoryData.reduce(0) { $0 + $1.1 }
                            )
                            .onTapGesture {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding()
                } else {
                    // 显示选中类别的详细列表
                    VStack(alignment: .leading, spacing: 12) {
                        // 返回按钮
                        Button(action: { selectedCategory = nil }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("返回")
                            }
                        }
                        .padding(.horizontal)
                        
                        // 详细列表
                        ForEach(bills.filter { $0.transaction?.category == selectedCategory }
                            .sorted { $0.amount > $1.amount }) { bill in
                                BillRowView(bill: bill)
                                    .padding(.horizontal)
                            }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("收支明细")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.accentColor.color)
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            if selectedTimeRange == .month {
                MonthPickerView(selectedDate: $selectedDate)
                    .presentationDetents([.height(300)])
            } else {
                YearPickerView(selectedDate: $selectedDate)
                    .presentationDetents([.height(300)])
            }
        }
        .onChange(of: selectedType) { _, _ in loadData() }
        .onChange(of: selectedTimeRange) { _, _ in loadData() }
        .onChange(of: selectedDate) { _, _ in loadData() }
        .task {
            loadData()
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
    }
    
    private func loadData() {
        guard let userID = userManager.currentUser?.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let calendar = Calendar.current
                let year = calendar.component(.year, from: selectedDate)
                let month = calendar.component(.month, from: selectedDate)
                
                if selectedTimeRange == .month {
                    bills = try await billAPI.getUserMonthlyBills(userID: userID, year: year, month: month)
                } else {
                    bills = try await billAPI.getUserYearlyBills(userID: userID, year: year)
                }
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    NavigationView {
        StatisticsTabView()
            .environmentObject(UserManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
