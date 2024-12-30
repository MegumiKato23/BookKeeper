import SwiftUI

struct BillSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: UserManager
    @StateObject private var billAPI = BillAPI()
    
    @State private var searchText = ""
    @State private var selectedType: TransactionType?
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showingStartDatePicker = false
    @State private var showingEndDatePicker = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchResults: [BillDTO] = []
    
    // 按类型筛选
    private func filterByType(_ bills: [BillDTO]) -> [BillDTO] {
        guard let type = selectedType else { return bills }
        return bills.filter { $0.transaction?.type == type }
    }
    
    // 按搜索文本筛选
    private func filterBySearchText(_ bills: [BillDTO]) -> [BillDTO] {
        guard !searchText.isEmpty else { return bills }
        return bills.filter { bill in
            let matchesCategory = bill.transaction?.category?.rawValue.contains(searchText) ?? false
            let matchesDescription = bill.description?.contains(searchText) ?? false
            let matchesAmount = String(format: "%.2f", bill.amount).contains(searchText)
            return matchesCategory || matchesDescription || matchesAmount
        }
    }
    
    // 最终的筛选结果
    private var filteredResults: [BillDTO] {
        let typeFiltered = filterByType(searchResults)
        let textFiltered = filterBySearchText(typeFiltered)
        return textFiltered.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchConditionView(
                    selectedType: $selectedType,
                    startDate: $startDate,
                    endDate: $endDate,
                    searchText: $searchText,
                    showingStartDatePicker: $showingStartDatePicker,
                    showingEndDatePicker: $showingEndDatePicker
                )
                
                SearchResultView(
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                    filteredResults: filteredResults,
                    retryAction: { Task { await searchBills() } }
                )
            }
            .navigationTitle("搜索账单")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("取消") { dismiss() })
            .sheet(isPresented: $showingStartDatePicker) {
                DatePickerSheet(date: $startDate)
                    .presentationDetents([.height(300)])
                    .onChange(of: startDate) { _, _ in
                        Task { await searchBills() }
                    }
            }
            .sheet(isPresented: $showingEndDatePicker) {
                DatePickerSheet(date: $endDate)
                    .presentationDetents([.height(300)])
                    .onChange(of: endDate) { _, _ in
                        Task { await searchBills() }
                    }
            }
            .onChange(of: selectedType) { _, _ in
                Task { await searchBills() }
            }
            .onChange(of: startDate) { _, _ in
                Task { await searchBills() }
            }
            .onChange(of: endDate) { _, _ in
                Task { await searchBills() }
            }
            .task {
                await searchBills()
            }
        }
    }
    
    private func searchBills() async {
        guard let userID = userManager.currentUser?.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            searchResults = try await billAPI.searchBills(
                userID: userID,
                startDate: startDate,
                endDate: endDate
            )
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

#Preview {
    BillSearchView()
        .environmentObject(UserManager.shared)
}
