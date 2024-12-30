import SwiftUI
import Charts

struct ChartView: View {
    let data: [(Date, Double)]
    let timeRange: TimeRange
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = timeRange == .month ? "d日" : "M月"
        return formatter
    }
    
    // 计算要显示的X轴标签
    private var xAxisValues: [Date] {
        guard !data.isEmpty else { return [] }
        let calendar = Calendar.current
        
        if timeRange == .month {
            // 月视图：筛选出每5天的日期
            return data.filter { date in
                let day = calendar.component(.day, from: date.0)
                return day == 1 || (day % 5 == 0 && day < 30)
            }.map { $0.0 }
        } else {
            // 年视图：筛选出每3个月的日期
            return data.filter { date in
                let month = calendar.component(.month, from: date.0)
                return month == 1 || month % 3 == 0
            }.map { $0.0 }
        }
    }
    
    private var maxAmount: Double {
        if let maxElement = data.max(by: { $0.1 < $1.1 }) {
            return maxElement.1
        }
        return 0
    }
    
    var body: some View {
        Chart {
            ForEach(data, id: \.0) { item in
                LineMark(
                    x: .value("日期", item.0),
                    y: .value("金额", item.1)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.monotone)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(position: .bottom, values: xAxisValues) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(dateFormatter.string(from: date))
                    }
                    AxisTick()
                    AxisGridLine()
                }
            }
        }
        .chartYScale(domain: [0, maxAmount])
        .frame(height: 200)
    }
}

// 时间范围枚举
enum TimeRange {
    case month, year
}


#Preview {
    let exampleData: [(Date, Double)] = [
        (Date().addingTimeInterval(-86400 * 30), 120.0),
        (Date().addingTimeInterval(-86400 * 29), 0),
        (Date().addingTimeInterval(-86400 * 28), 0),
        (Date().addingTimeInterval(-86400 * 27), 0),
        (Date().addingTimeInterval(-86400 * 26), 100.0),
        (Date().addingTimeInterval(-86400 * 25), 300.0),
        (Date().addingTimeInterval(-86400 * 24), 180.0),
        (Date().addingTimeInterval(-86400 * 23), 260.0),
        (Date().addingTimeInterval(-86400 * 22), 130.0),
        (Date().addingTimeInterval(-86400 * 21), 0.0),
        (Date().addingTimeInterval(-86400 * 20), 100.0),
        (Date().addingTimeInterval(-86400 * 19), 290.0),
        (Date().addingTimeInterval(-86400 * 18), 160.0),
        (Date().addingTimeInterval(-86400 * 17), 230.0),
        (Date().addingTimeInterval(-86400 * 16), 110.0),
        (Date().addingTimeInterval(-86400 * 15), 300.0),
        (Date().addingTimeInterval(-86400 * 14), 190.0),
        (Date().addingTimeInterval(-86400 * 13), 270.0),
        (Date().addingTimeInterval(-86400 * 12), 140.0),
        (Date().addingTimeInterval(-86400 * 11), 220.0),
        (Date().addingTimeInterval(-86400 * 10), 105.0),
        (Date().addingTimeInterval(-86400 * 9), 295.0),
        (Date().addingTimeInterval(-86400 * 8), 165.0),
        (Date().addingTimeInterval(-86400 * 7), 235.0),
        (Date().addingTimeInterval(-86400 * 6), 115.0),
        (Date().addingTimeInterval(-86400 * 5), 305.0),
        (Date().addingTimeInterval(-86400 * 4), 195.0),
        (Date().addingTimeInterval(-86400 * 3), 275.0),
        (Date().addingTimeInterval(-86400 * 2), 145.0),
        (Date().addingTimeInterval(-86400 * 1), 225.0),
        (Date(), 250.0)
    ]
    ChartView(data: exampleData, timeRange: .month)
}
