//
//  CustomKeyboard.swift
//  AccountBook
//
//  Created by 周广 on 2024/12/14.
//

import SwiftUI

struct CustomKeyboard: View {
    @Binding var input: String
    @Binding var showingDatePicker: Bool
    let canSave: Bool
    let onSave: () -> Void
    
    private let keyboardButtons: [[String]] = [
        ["7", "8", "9", "+"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "⌫"],
        [".", "0", "00", "完成"]
    ]
    
    var body: some View {
        VStack(spacing: 1) {
            ForEach(keyboardButtons, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(row, id: \.self) { key in
                        Button(action: { handleKeyPress(key) }) {
                            if key == "⌫" {
                                Image(systemName: "delete.left")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color(.systemBackground))
                                    .foregroundColor(.primary)
                            } else if key == "完成" {
                                Text(containsOperator(input) ? "计算" : "完成")
                                    .bold()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(canSave ? Color.blue : Color(.systemGray4))
                                    .foregroundColor(.white)
                            } else {
                                Text(key)
                                    .font(.title2)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color(.systemBackground))
                                    .foregroundColor([".", "+", "-"].contains(key) ? .blue : .primary)
                            }
                        }
                        .disabled(key == "完成" && !canSave)
                    }
                }
            }
            
            // 日期选择按钮
//            Button(action: { showingDatePicker = true }) {
//                HStack {
//                    Image(systemName: "calendar")
//                    Text(Date().chineseStyleString)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color(.systemBackground))
//                .foregroundColor(.blue)
//            }

        }
        .frame(height: 280)
        .background(Color(.systemGray4))
    }
    
    private func handleKeyPress(_ key: String) {
        switch key {
        case "⌫":
            if !input.isEmpty {
                input.removeLast()
            }
        case "完成":
            if containsOperator(input) {
                if let result = calculateFinalResult() {
                    input = String(format: "%.2f", result)
                }
            } else if !input.isEmpty {
                onSave()
            }
        case ".":
            if canAddDecimalPoint() {
                input += input.isEmpty ? "0." : "."
            }
        case "00":
            if canAddZeros() {
                input += input.isEmpty ? "0" : "00"
            }
        case "+", "-":
            if canAddOperator(key) {
                input += key
            }
        default:
            if canAddDigit(key) {
                input += key
            }
        }
    }
    
    // 检查是否包含运算符（不包括开头的负号）
    private func containsOperator(_ str: String) -> Bool {
        guard str.count > 1 else { return false }
        let startIndex = str.startIndex
        let rest = str[str.index(after: startIndex)...]
        return rest.contains(where: { "+-".contains($0) })
    }
    
    // 检查是否可以添加小数点
    private func canAddDecimalPoint() -> Bool {
        let numbers = input.split(whereSeparator: { "+-".contains($0) })
        guard let lastNumber = numbers.last else { return true }
        return !String(lastNumber).contains(".")
    }
    
    // 检查是否可以添加数字
    private func canAddDigit(_ digit: String) -> Bool {
        // 如果输入为空或最后一个字符是运算符，总是可以添加数字
        if input.isEmpty || ["+", "-"].contains(input.last!) {
            return true
        }
        
        // 获取最后一个数字（从最后一个运算符到结尾）
        var lastNumber = input
        if let lastOperatorRange = input.rangeOfCharacter(from: CharacterSet(charactersIn: "+-"), options: .backwards) {
            lastNumber = String(input[lastOperatorRange.upperBound...])
        }
        
        // 检查小数位数
        if lastNumber.contains(".") {
            let parts = lastNumber.split(separator: ".")
            if parts.count == 2 {
                return parts[1].count < 2
            }
        }
        
        return true
    }
    
    // 检查是否可以添加运算符
    private func canAddOperator(_ op: String) -> Bool {
        if input.isEmpty {
            return op == "-" // 只有减号可以作为第一个字符
        }
        // 确保最后一个字符不是运算符或小数点
        return ![".", "+", "-"].contains(input.last!)
    }
    
    // 检查是否可以添加00
    private func canAddZeros() -> Bool {
        if input.isEmpty { return true }
        
        let numbers = input.split(whereSeparator: { "+-".contains($0) })
        guard let lastNumber = numbers.last else { return true }
        
        // 如果最后一个数字包含小数点，不允许添加00
        if lastNumber.contains(".") { return false }
        
        // 如果最后一个数字是0，不允许添加00
        return lastNumber != "0"
    }
    
    // 计算最终结果
    private func calculateFinalResult() -> Double? {
        // 分割数字和运算符
        var numbers: [Double] = []
        var operators: [String] = []
        
        // 处理第一个数字可能是负数的情况
        var currentNumber = ""
        var isFirstChar = true
        
        for char in input {
            if isFirstChar && char == "-" {
                currentNumber.append(char)
                isFirstChar = false
                continue
            }
            isFirstChar = false
            
            if "+-".contains(char) {
                guard let number = Double(currentNumber) else { return nil }
                numbers.append(number)
                operators.append(String(char))
                currentNumber = ""
            } else {
                currentNumber.append(char)
            }
        }
        
        // 添加最后一个数字
        guard let lastNumber = Double(currentNumber) else { return nil }
        numbers.append(lastNumber)
        
        // 如果数字数量不正确，返回nil
        guard numbers.count == operators.count + 1 else { return nil }
        
        // 执行计算
        var result = numbers[0]
        
        for i in 0..<operators.count {
            let nextNumber = numbers[i + 1]
            switch operators[i] {
            case "+":
                result += nextNumber
            case "-":
                result -= nextNumber
            default:
                return nil
            }
        }
        
        return result
    }
}

// 添加一个计算器辅助类
struct CustomCalculator {
    init() { }
    
    func calculate(_ expression: String) -> Double? {
        // 分割数字和运算符
        var numbers: [Double] = []
        var operators: [String] = []
        
        // 处理第一个数字可能是负数的情况
        var currentNumber = ""
        var isFirstChar = true
        
        for char in expression {
            if isFirstChar && char == "-" {
                currentNumber.append(char)
                isFirstChar = false
                continue
            }
            isFirstChar = false
            
            if "+-".contains(char) {
                if let number = Double(currentNumber) {
                    numbers.append(number)
                } else {
                    return nil
                }
                operators.append(String(char))
                currentNumber = ""
            } else {
                currentNumber.append(char)
            }
        }
        
        // 添加最后一个数字
        if let number = Double(currentNumber) {
            numbers.append(number)
        } else {
            return nil
        }
        
        // 如果数字数量不正确，返回nil
        if numbers.count != operators.count + 1 {
            return nil
        }
        
        // 执行计算
        var result = numbers.first ?? 0
        
        for i in 0..<operators.count {
            let nextNumber = numbers[i + 1]
            switch operators[i] {
            case "+":
                result += nextNumber
            case "-":
                result -= nextNumber
            default:
                return nil
            }
        }
        
        return result
    }
}
