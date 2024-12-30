import SwiftUI

struct BillListView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var billAPI: BillAPI = BillAPI()
    @StateObject private var budgetAPI: BudgetAPI = BudgetAPI()
    @StateObject private var accountAPI: AccountAPI = AccountAPI()
    
    @State private var selectedDate = Date()
    @State private var showingBudgetSheet = false
    @State private var showingAddBill = false
    @State private var showingStatistics = false
    @State private var showingSearch = false
    @State private var statisticsType: TransactionType = .expense
    @State private var showingMonthPicker = false
    @State private var showingSuccessAlert = false
    @State private var isLoading = false
    
    // 数据状态
    @State private var bills: [BillDTO] = []
    @State private var budget: BudgetDTO?
    @State private var errorMessage: String?
    @State private var balanceMonthly: BalanceResponse?
    
    private var sortedBills: [BillDTO] {
        bills.sorted { $0.date > $1.date }  // 按日期降序排列
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }
    
    private var isCurrentMonth: Bool {
        let calendar = Calendar.current
        return calendar.isDate(selectedDate, equalTo: Date(), toGranularity: .month)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 月份选择和统计
                VStack(spacing: 16) {
                    // 月份选择器
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(themeManager.accentColor.color)
                        Text(dateFormatter.string(from: selectedDate))
                            .foregroundColor(.primary)
                            .onTapGesture {
                                withAnimation {
                                    showingMonthPicker = true
                                }
                            }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 收支统计
                    HStack(spacing: 20) {
                        StatisticButton(title: "支出",
                                      amount: balanceMonthly?.totalExpense ?? 0,
                                      type: .expense) {
                            statisticsType = .expense
                            showingStatistics = true
                        }
                        
                        StatisticButton(title: "收入",
                                      amount: balanceMonthly?.totalIncome ?? 0,
                                      type: .income) {
                            statisticsType = .income
                            showingStatistics = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // 预算进度
                    if isCurrentMonth {
                        BudgetProgressView(spent: balanceMonthly?.totalExpense ?? 0,
                                         budget: budget?.budget ?? 0)
                            .padding(.horizontal)
                            .onTapGesture {
                                showingBudgetSheet = true
                            }
                    }
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                .shadow(radius: 1)
                
                // 账单列表
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(.secondary)
                        Button("重试") {
                            Task {
                                await loadData()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if bills.isEmpty {
                    EmptyBillView()
                } else {
                    List {
                        ForEach(sortedBills) { bill in
                            NavigationLink(destination: BillDetailView(bill: binding(for: bill))) {
                                BillRowView(bill: bill)
                            }
                        }
                        .onDelete(perform: deleteBill(indexes:))
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await loadData()
                    }
                }
            }
            
            // 浮动添加按钮
            if isCurrentMonth {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddBill = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(themeManager.accentColor.color)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("账单明细")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.accentColor.color)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    selectedDate = Date()
                    Task {
                        await loadData()
                    }
                }) {
                    Text("现在")
                        .foregroundColor(isCurrentMonth ? .secondary : themeManager.accentColor.color)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingSearch = true }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(themeManager.accentColor.color)
                }
            }
        }
        .sheet(isPresented: $showingBudgetSheet) {
			BudgetSettingView(budget: $budget)
                .onDisappear {
                    Task { @MainActor in
                        await loadData()
                    }
                }
        }
        .sheet(isPresented: $showingAddBill) {
            AddBillView()
                .onDisappear {
                    Task { @MainActor in
                        await loadData()
                    }
                }
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView(type: statisticsType, bills: balanceMonthly?.bills ?? bills)
        }
        .sheet(isPresented: $showingMonthPicker) {
            MonthPickerView(selectedDate: $selectedDate)
                .presentationDetents([.height(300)])
                .onDisappear {
                    Task { @MainActor in
                        await loadData()
                    }
                }
        }
        .sheet(isPresented: $showingSearch) {
            BillSearchView()
        }
        .alert("删除成功", isPresented: $showingSuccessAlert) {
            Button("确定") {
                Task { @MainActor in
                    await loadData()
                }
            }
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        guard let userID = userManager.currentUser?.id else {
            return
        }
        
        Task {
            do {
                budget = try await budgetAPI.getBudget(type: "月预算", userID: userID)
                bills = try await billAPI.getUserBills(userID: userID)
                try await loadMonthlyBalance()
                
            } catch {
                errorMessage = "获取账单失败!"
            }
        }
    }
    
    // 加载月份收支明细
    private func loadMonthlyBalance() async throws {
        guard let userID = userManager.currentUser?.id else {
            return
        }
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        balanceMonthly = try await accountAPI.getMonthlyBalance(userID: userID, year: year, month: month)
        if !isCurrentMonth {
            guard let billsMonthly = balanceMonthly?.bills else {
                bills = []
                return
            }
            bills = billsMonthly
        }
    }
    
    // 删除账单
    private func deleteBill(indexes: IndexSet) {
        for index in indexes {
            // 获取要删除的账单ID
            let billToDelete = sortedBills[index]
            guard let billID = billToDelete.id else {
                return
            }
            
            Task { @MainActor in
                try await billAPI.deleteBill(billID: billID) { result in
                    switch result {
                        case .success(_):
                            showingSuccessAlert = true
                        case .failure(let error):
                            errorMessage = "\(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func binding(for bill: BillDTO) -> Binding<BillDTO> {
        guard let index = bills.firstIndex(where: { $0.id == bill.id }) else {
            fatalError("Bill not found")
        }
        return $bills[index]
    }
}

struct StatisticButton: View {
    let title: String
    let amount: Double
    let type: TransactionType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("¥\(String(format: "%.2f", amount))")
                    .font(.headline)
                    .foregroundColor(type == .expense ? .red : .green)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationView {
        BillListView()
            .environmentObject(UserManager.shared)
            .environmentObject(ThemeManager.shared)
    }
} 
