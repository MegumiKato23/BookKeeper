import SwiftUI

struct AboutView: View {
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        List {
            // App 信息
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.blue)
                    
                    Text("记账本")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("版本 \(version) (\(build))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .listRowBackground(Color.clear)
            }
            
            // 功能介绍
            Section {
                Text("记账本是一款简单易用的个人记账应用，帮助您轻松管理日常收支，实现理财目标。")
                    .font(.body)
                    .foregroundColor(.secondary)
            } header: {
                Text("关于")
            }
            
            // 开发者信息
            Section {
                HStack {
                    Text("开发者")
                    Spacer()
                    Text("zg")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("联系邮箱")
                    Spacer()
                    Text("531197875@qq.com")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("开发者信息")
            }
            
            // 功能特点
            Section {
                FeatureRow(icon: "list.bullet", title: "记账明细", description: "清晰记录每一笔收支")
                FeatureRow(icon: "chart.pie", title: "统计分析", description: "多维度分析收支情况")
                FeatureRow(icon: "target", title: "预算管理", description: "合理规划月度支出")
                FeatureRow(icon: "bell", title: "智能提醒", description: "及时提醒记账和预算")
            } header: {
                Text("主要功能")
            }
            
            // 版权信息
            Section {
                Text("© 2024 zg. All rights reserved.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
} 
