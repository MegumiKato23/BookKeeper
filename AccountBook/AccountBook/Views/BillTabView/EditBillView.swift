import SwiftUI

struct EditBillView: View {
    @Binding var bill: BillDTO
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: UserManager
    @StateObject private var billAPI = BillAPI()
    @StateObject private var transactionAPI = TransactionAPI()
    
    @State private var amount: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: TransactionCategory?
    @State private var description: String = ""
    @State private var date: Date = Date()
    
    @State private var showingDeleteAlert = false
    @State private var showingDatePicker = false
    @State private var showingDescriptionField = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    
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
                    
                    // 删除按钮
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Text("删除这笔账单")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            
            // 数字键盘
            CustomKeyboard(input: $amount,
                         showingDatePicker: $showingDatePicker,
                           canSave: isValidAmount) {
                saveBill()
                dismiss()
            }
            Spacer()
        }
        .navigationTitle("编辑账单")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button("取消") { dismiss() },
            trailing: Button("保存") {
                saveBill()
                dismiss()
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
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("删除", role: .destructive) {
                deleteBill()
                dismiss()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("删除后无法恢复，是否确认删除？")
        }
        .onAppear {
            // 初始化表单数据
            amount = String(format: "%.2f", bill.amount)
            if let transaction = bill.transaction {
                selectedType = transaction.type ?? .expense
                selectedCategory = transaction.category
            }
            description = bill.description ?? ""
            date = bill.date
        }
        .overlay {
            if isLoading {
                Color.black.opacity(0.3)
                ProgressView()
                    .tint(.white)
            }
        }
    }
    
    private func saveBill() {
        guard let amount = Double(amount),
              let category = selectedCategory else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            
            if (category != bill.transaction?.category) {
                bill.transaction = try await transactionAPI.getCategoryId(category: category.rawValue)
            }
            guard let transactionID = bill.transaction?.id else {
                return
            }
            bill.amount = amount
            bill.date = date
            bill.description = description.isEmpty ? nil : description
            
            try await billAPI.updateBill(bill: bill, transactionID: transactionID) { result in
                switch result {
                    case .success(_):
                        isLoading = false
                    case .failure(let error):
                        errorMessage = "删除失败：\(error.localizedDescription)"
                        isLoading = false
                }
            }
        }
    }
    
    private func deleteBill() {
        guard let billID = bill.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            try await billAPI.deleteBill(billID: billID) { result in
                switch result {
                    case .success(_):
                        isLoading = false
                    case .failure(let error):
                        errorMessage = "删除失败：\(error.localizedDescription)"
                        isLoading = false
                }
            }
        }
    }
}

struct CategorySelectButton: View {
    let category: TransactionCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                Text(category.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 64, height: 80)
            .background(isSelected ? Color(category.colorName) : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

#Preview(body: {
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
        EditBillView(bill: $bill)
    }
})
