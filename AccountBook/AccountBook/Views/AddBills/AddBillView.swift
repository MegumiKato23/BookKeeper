import SwiftUI

struct AddBillView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: UserManager
    @StateObject private var billAPI = BillAPI()
    @StateObject private var transactionAPI = TransactionAPI()
    
    @State private var amount: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: TransactionCategory?
    @State private var description: String = ""
    @State private var date = Date()
    
    @State private var showingDatePicker = false
    @State private var showingDescriptionField = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showingSuccessAlert = false
    
    private var isValidAmount: Bool {
        // 如果输入为空，返回false
        if amount.isEmpty { return false }
        
        // 如果只包含一个负号，返回false
        if amount == "-" { return false }
        
        // 如果包含运算符，尝试计算结果
        if containsOperator(amount) {
            let calculator = CustomCalculator()
            if let result = calculator.calculate(amount) {
                return result > 0
            }
            return false
        }
        
        // 如果是单个数字，直接判断
        if let value = Double(amount) {
            return value > 0
        }
        
        return false
    }
    
    // 检查是否包含运算符（不包括开头的负号）
    private func containsOperator(_ str: String) -> Bool {
        guard str.count > 1 else { return false }
        let startIndex = str.startIndex
        let rest = str[str.index(after: startIndex)...]
        return rest.contains(where: { "+-".contains($0) })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        // 金额显示
                        HStack {
                            Text("¥")
                                .font(.system(size: 28, weight: .medium))
                            Text(amount.isEmpty ? "0.00" : amount)
                                .font(.system(size: 36, weight: .medium))
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        
                        // 类型选择
                        Section {
                            Picker("类型", selection: $selectedType) {
                                Text(TransactionType.expense.rawValue).tag(TransactionType.expense)
                                Text(TransactionType.income.rawValue).tag(TransactionType.income)
                            }
                            .pickerStyle(.segmented)
                            .padding()
                            .onChange(of: selectedType) { _, newType in
                                // 切换类型时，自动选择新类型下的第一个类别
                                let categories = newType == .expense ?
                                    TransactionCategory.expenseCategories :
                                    TransactionCategory.incomeCategories
                                selectedCategory = categories[0]
                            }
                        }
                        
                        // 类别选择
                        Section {
                            let categories = selectedType == .expense ?
                                TransactionCategory.expenseCategories :
                                TransactionCategory.incomeCategories
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(categories, id: \.self) { category in
                                        CategorySelectButton(
                                            category: category,
                                            isSelected: selectedCategory == category
                                        ) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                        
                        // 日期和备注
                        HStack {
                            Button(action: { showingDatePicker.toggle() }) {
                                Label(date.chineseStyleString,
                                      systemImage: "calendar")
                            }
                            
                            Spacer()
                            
                            Button(action: { showingDescriptionField.toggle() }) {
                                Label(description.isEmpty ? "添加备注" : description,
                                      systemImage: "square.and.pencil")
                            }
                        }
                        .foregroundColor(.secondary)
                        .padding()
                    }
                }
                
                // 数字键盘
                CustomKeyboard(input: $amount,
                             showingDatePicker: $showingDatePicker,
                               canSave: isValidAmount) {
                    saveBill()
                }
                Spacer()
            }
            .navigationTitle("记一笔")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("保存") {
                    saveBill()
                }
                .disabled(!isValidAmount || isLoading)
            )
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(date: $date)
                    .presentationDetents([.height(300)])
            }
            .sheet(isPresented: $showingDescriptionField) {
                NoteInputSheet(note: $description)
                    .presentationDetents([.height(150)])
            }
            .alert("添加成功", isPresented: $showingSuccessAlert) {
                Button("继续添加") {
                    resetForm()
                }
                Button("完成") {
                    dismiss()
                }
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                    ProgressView()
                        .tint(.white)
                }
            }
            .onAppear {
                // 默认选择第一个支出类别
                selectedCategory = TransactionCategory.expenseCategories[0]
            }
        }
    }
    
    private func saveBill() {
        guard let amount = Double(amount),
              let category = selectedCategory,
              let userID = userManager.currentUser?.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            // 创建交易类型
            let transaction = try await transactionAPI.getCategoryId(category: category.rawValue)
            
            // 创建账单
            let bill = BillDTO(
                amount: amount,
                date: date,
                description: description.isEmpty ? nil : description
            )
            
            try await billAPI.createBill(bill: bill, userID: userID, transactionID: transaction.id!) { result in
                switch result {
                    case .success(_):
                        isLoading = false
                        showingSuccessAlert = true
                        
                    case .failure(let error):
                        errorMessage = "保存失败：\(error.localizedDescription)"
                        isLoading = false
                }
            }
        }
        
    }
    
    private func resetForm() {
        amount = ""
        description = ""
        date = Date()
        selectedType = .expense
        selectedCategory = TransactionCategory.expenseCategories[0]
        errorMessage = nil
        isLoading = false
    }
}

#Preview {
    AddBillView()
} 
