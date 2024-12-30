import SwiftUI

struct NotificationSettingView: View {
    @AppStorage("enableBudgetAlert") private var enableBudgetAlert = true
    @AppStorage("budgetAlertThreshold") private var budgetAlertThreshold = 80.0
    @AppStorage("enableDailyReminder") private var enableDailyReminder = false
    @AppStorage("dailyReminderTime") private var dailyReminderTime = Date()
    @AppStorage("enableMonthlyReport") private var enableMonthlyReport = true
    
    @State private var showingTimePicker = false
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        Form {
            // 预算提醒
            Section {
                Toggle("预算提醒", isOn: $enableBudgetAlert)
                
                if enableBudgetAlert {
                    VStack(alignment: .leading) {
                        Text("提醒阈值：\(Int(budgetAlertThreshold))%")
                        Slider(value: $budgetAlertThreshold, in: 50...100, step: 5)
                    }
                }
            } header: {
                Text("预算提醒")
            } footer: {
                Text("当月支出达到预算的指定百分比时提醒")
            }
            
            // 每日提醒
            Section {
                Toggle("每日记账提醒", isOn: $enableDailyReminder)
                
                if enableDailyReminder {
                    HStack {
                        Text("提醒时间")
                        Spacer()
                        Button(action: { showingTimePicker = true }) {
                            Text(timeFormatter.string(from: dailyReminderTime))
                                .foregroundColor(.primary)
                        }
                    }
                }
            } header: {
                Text("每日提醒")
            } footer: {
                Text("在指定时间提醒记账")
            }
            
            // 月度报告
            Section {
                Toggle("月度收支报告", isOn: $enableMonthlyReport)
            } header: {
                Text("月度报告")
            } footer: {
                Text("每月初生成上月收支报告")
            }
        }
        .navigationTitle("通知设置")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingTimePicker) {
            NavigationView {
                DatePicker("选择时间",
                          selection: $dailyReminderTime,
                          displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .navigationTitle("选择提醒时间")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(
                        trailing: Button("完成") {
                            showingTimePicker = false
                        }
                    )
                    .padding()
            }
            .presentationDetents([.height(300)])
        }
        .onChange(of: enableBudgetAlert) { _, _ in
            updateNotificationSettings()
        }
        .onChange(of: enableDailyReminder) { _, _ in
            updateNotificationSettings()
        }
        .onChange(of: enableMonthlyReport) { _, _ in
            updateNotificationSettings()
        }
        .onChange(of: dailyReminderTime) { _, _ in
            updateNotificationSettings()
        }
    }
    
    private func updateNotificationSettings() {
        // TODO: 实现通知
    }
}

#Preview {
    NavigationView {
        NotificationSettingView()
    }
} 
