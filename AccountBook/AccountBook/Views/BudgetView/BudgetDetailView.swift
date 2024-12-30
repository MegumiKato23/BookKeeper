import SwiftUI

struct BudgetDetailView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var budgetAPI = BudgetAPI()
	@StateObject private var accountAPI = AccountAPI()
    
    @State private var yearlyBudget: BudgetDTO?
    @State private var monthlyBudget: BudgetDTO?
	@State private var yearlyExpense: Double = 0
	@State private var monthlyExpense: Double = 0
    @State private var bills: [BillDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingBudgetSheet = false
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    private var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }
    
    // 年度预算使用百分比
    private var yearlyPercentage: Double {
        guard let budget = yearlyBudget?.budget, budget > 0 else { return 0 }
        return min(yearlyExpense / budget, 1.0)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 年度预算圆环
                VStack(spacing: 16) {
                    Text("\(currentYear)年总预算")
                        .font(.headline)
                    
                    ZStack {
                        // 背景圆环
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 20)
                            .frame(width: 200, height: 200)
                        
                        // 进度圆环
                        Circle()
                            .trim(from: 0, to: yearlyPercentage)
                            .stroke(
								yearlyExpense > (yearlyBudget?.budget ?? 0) ? Color.red : themeManager.accentColor.color,
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                        
                        // 中心文字
                        VStack(spacing: 8) {
                            Text("剩余预算")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
							if let budget = yearlyBudget?.budget {
                                Text("¥ \(String(format: "%.2f", max(budget - yearlyExpense, 0)))")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.primary)
                            } else {
                                Text("未设置")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // 预算详情
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text("年度预算")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("¥ \(String(format: "%.2f", yearlyBudget?.budget ?? 0))")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 8) {
                            Text("已使用")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("¥ \(String(format: "%.2f", yearlyExpense))")
                                .font(.headline)
                        }
                    }
                    
                    // 设置预算按钮
                    Button(action: { showingBudgetSheet = true }) {
                        Text(yearlyBudget == nil ? "设置预算" : "修改预算")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 40)
                            .background(themeManager.accentColor.color)
                            .cornerRadius(20)
                    }
                }
                .padding()
				.frame(width: 350)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // 月度统计
                VStack(spacing: 16) {
                    Text("\(currentMonth)月支出统计")
                        .font(.headline)
                    
                    if let monthlyBudget = monthlyBudget {
                        VStack(spacing: 8) {
                            // 进度条
							ProgressView(value: monthlyExpense, total: monthlyBudget.budget)
								.tint(monthlyExpense > monthlyBudget.budget ? .red : themeManager.accentColor.color)
                            
                            // 金额说明
                            HStack {
                                Text("已使用 ¥\(String(format: "%.2f", monthlyExpense))")
                                Spacer()
                                Text("共 ¥\(String(format: "%.2f", monthlyBudget.budget))")
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        }
                    } else {
                        Text("未设置月度预算")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text("预算详情")
					.font(.title2)
					.fontWeight(.bold)
					.foregroundColor(themeManager.accentColor.color)
			}
		}
        .sheet(isPresented: $showingBudgetSheet) {
			BudgetSettingView(budget: $yearlyBudget)
                .onDisappear {
                    Task {
                        await loadData()
                    }
                }
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
        .task {
            await loadData()
        }
        .refreshable {
            await loadData()
        }
    }
    
    private func loadData() async {
        guard let userID = userManager.currentUser?.id else { return }
        
        isLoading = true
        errorMessage = nil
        
		Task { @MainActor in
			do {
				// 并行获取所有数据
				async let yearlyBudgetResult = budgetAPI.getBudget(type: "年预算", userID: userID)
				async let monthlyBudgetResult = budgetAPI.getBudget(type: "月预算", userID: userID)
				async let yearlyBalanceResult = accountAPI.getYearlyBalance(userID: userID, year: currentYear)
				async let monthlyBalanceResult = accountAPI.getMonthlyBalance(userID: userID, year: currentYear, month: currentMonth)
				
				// 等待所有结果
				do {
					yearlyBudget = try await yearlyBudgetResult
				} catch {
					print("获取年度预算失败: \(error.localizedDescription)")
				}
				
				do {
					monthlyBudget = try await monthlyBudgetResult
				} catch {
					print("获取月度预算失败: \(error.localizedDescription)")
				}
				
				do {
					let yearlyBalance = try await yearlyBalanceResult
					yearlyExpense = yearlyBalance.totalExpense
				} catch {
					print("获取年度支出失败: \(error.localizedDescription)")
				}
				
				do {
					let monthlyBalance = try await monthlyBalanceResult
					monthlyExpense = monthlyBalance.totalExpense
				} catch {
					print("获取月度支出失败: \(error.localizedDescription)")
				}
			} catch {
				errorMessage = "部分数据获取失败"
			}
			
			isLoading = false
		}
    }
}

#Preview {
    NavigationView {
        BudgetDetailView()
            .environmentObject(UserManager.shared)
            .environmentObject(ThemeManager.shared)
    }
} 
