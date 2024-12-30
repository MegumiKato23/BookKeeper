import SwiftUI

struct CategoryCard: View {
    let category: TransactionCategory
    let amount: Double
    let total: Double
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return amount / total * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.iconName)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Color(category.colorName))
                    .cornerRadius(8)
                
                Text(category.rawValue)
                    .font(.subheadline)
            }
            
            Text("¥\(String(format: "%.2f", amount))")
                .font(.headline)
            
            Text(String(format: "%.1f%%", percentage))
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: percentage, total: 100)
                .tint(Color(category.colorName))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
