import SwiftUI

struct BudgetSettingView: View {
    @Binding var budget: BudgetDTO?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: UserManager
    @StateObject private var budgetAPI = BudgetAPI()
    @State private var amount: String = ""
    @State private var selectedType: BudgetType = .month
    @State private var description: String = ""
    
    @State private var showingAlert = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    private var isValidAmount: Bool {
        guard let value = Double(amount) else { return false }
        return value > 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    HStack {
                        Text("¥")
                            .foregroundColor(.secondary)
                        TextField("输入预算金额", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("预算类型", selection: $selectedType) {
                        Text(BudgetType.month.rawValue).tag(BudgetType.month)
                        Text(BudgetType.year.rawValue).tag(BudgetType.year)
                    }
                    
                    TextField(budget?.description == "" ? "备注(可选)" : budget?.description ?? "备注(可选)", text: $description)
                        .keyboardType(.decimalPad)
                    
                } header: {
                    Text("预算设置")
                } footer: {
                    Text("设置预算可以帮助您更好地控制支出")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
            }
            .navigationTitle("设置预算")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("保存") {
                    saveBudget()
                }
                .disabled(!isValidAmount || isLoading)
            )
            .alert("预算设置成功", isPresented: $showingAlert) {
                Button("确定") { dismiss() }
            }
            .onAppear {
                if let budget = budget {
                    amount = String(format: "%.2f", budget.budget)
                    if let type = budget.type {
                        selectedType = type
                    }
                }
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                    ProgressView()
                        .tint(.white)
                }
            }
        }
    }
    
    private func saveBudget() {
        guard let amount = Double(amount) else { return }
        guard let userID = userManager.currentUser?.id else {
            errorMessage = "用户ID无效"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            if budget != nil {
                let updatedBudget = BudgetDTO(budget: amount, description: description, type: selectedType)
                try await budgetAPI.updateBudget(userID: userID, budget: updatedBudget) { result in
                    switch result {
                        case .success(let newBudget):
                            budget = newBudget
                        case .failure(let error):
                            errorMessage = "保存失败：\(error.localizedDescription)"
                            isLoading = false
                    }
                }
            } else {
                let newBudget = BudgetDTO(budget: amount, description: description, type: selectedType)
                try await budgetAPI.createBudget(userID: userID, budget: newBudget) { result in
                    switch result {
                        case .success(_):
                            budget = newBudget
                        case .failure(let error):
                            errorMessage = "保存失败：\(error.localizedDescription)"
                            isLoading = false
                    }
                }
            }
            showingAlert = true
        }
    }
}

