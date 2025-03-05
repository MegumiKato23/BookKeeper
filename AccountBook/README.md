# AccountBook 记账应用

<p align="center">
<img src="https://img.shields.io/badge/Swift-5.9-orange.svg" />
<img src="https://img.shields.io/badge/iOS-16.0%2B-blue.svg" />
</p>

基于 SwiftUI 开发的优雅直观的个人理财 iOS 应用，提供全面的支出跟踪和预算管理功能，并采用现代化的用户界面设计。

## ✨ 功能特点

- 📊 **月度报表概览**
- 详细的每月支出跟踪
- 可视化支出趋势和模式
- 自定义日期范围视图

- 💰 **收支管理**
- 多类别支持
- 详细的交易历史记录
- 快速交易录入
- 自定义类别创建

- 📈 **预算规划**
- 月度预算设置
- 分类预算分配
- 预算与实际支出分析
- 超支提醒


## 🛠 技术栈

- **SwiftUI** - 现代声明式 UI 框架
- **Swift Async/Await** - 现代并发处理
- **Charts Framework** - 原生数据可视化
- **MVVM Architecture** - 清晰的关注点分离
- **Core Data** - 本地数据持久化
- **SwiftLint** - 代码质量控制

## 📁 项目结构

```
AccountBook/
├── Views/           # 界面组件
│   ├── Main/        # 主要视图
│   ├── Detail/      # 详情视图
│   ├── Add/         # 交易录入视图
│   └── Profile/     # 用户档案视图
├── Models/          # 数据模型
├── ViewModels/      # 视图模型
└── Utils/           # 工具类
```

## ⚙️ 系统要求

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## 🏗 架构

应用采用 MVVM (Model-View-ViewModel) 架构：
- **Models**: 核心数据模型和业务逻辑
- **Views**: SwiftUI 视图和 UI 组件
- **ViewModels**: 数据绑定和业务逻辑处理
- **Utils**: 辅助函数和扩展

## 🔒 隐私与安全

- 本地数据加密
- 安全认证
- 隐私数据处理
- 定期安全更新
