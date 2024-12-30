import SwiftUI

struct BudgetProgressView: View {
    let spent: Double
    let budget: Double
    
    private var progress: Double {
        guard budget > 0 else { return 0 }
        return min(spent / budget, 1.0)
    }
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return .red
        } else if progress >= 0.8 {
            return .orange
        } else {
            return .blue
        }
    }
    
    private var progressText: String {
        if budget <= 0 {
            return "未设置预算"
        } else if progress >= 1.0 {
            return "已超预算"
        } else {
            return "已使用 \(Int(progress * 100))%"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("本月预算")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("¥\(String(format: "%.2f", budget))")
                    .font(.headline)
            }
            
            ProgressView(value: progress)
                .tint(progressColor)
            
            HStack {
                Text(progressText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if progress >= 1.0 {
                    Text("超支 ¥\(String(format: "%.2f", spent - budget))")
                        .font(.caption)
                        .foregroundColor(.red)
                } else if budget > 0 {
                    Text("剩余 ¥\(String(format: "%.2f", budget - spent))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    VStack(spacing: 20) {
        BudgetProgressView(spent: 800, budget: 1000)
        BudgetProgressView(spent: 900, budget: 1000)
        BudgetProgressView(spent: 1200, budget: 1000)
        BudgetProgressView(spent: 100, budget: 0)
    }
    .padding()
} 
