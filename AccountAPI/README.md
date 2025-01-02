# AccountAPI Backend Service / AccountAPI 后端服务

[![Swift](https://img.shields.io/badge/swift-6.0-orange.svg)](https://swift.org)
[![Vapor](https://img.shields.io/badge/vapor-4.0-blue.svg)](https://vapor.codes)
[![MySQL](https://img.shields.io/badge/mysql-8.0-blue.svg)](https://www.mysql.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

基于 Vapor 框架开发的强大后端服务，为 AccountBook iOS 应用提供全面的个人财务管理 API 支持。

This is a robust backend service developed with Vapor framework for the AccountBook iOS application, providing comprehensive API support for personal finance management.

## Requirements and Technical Stack / 技术栈

- Swift 6.0+
- Vapor Framework 4.0
- MySQL 8.0+
- Fluent ORM 4.0
- Docker 20.10+ (for deployment)
- Xcode 13.0+ (for development)

## Features / 核心功能

- 用户认证与授权 (User Authentication and Authorization)
- 基于 JWT 的身份认证
- 基于角色的访问控制
- 账单管理 (Bill Management)
- 支持创建、读取、更新、删除操作
- 批量处理支持
- 预算追踪 (Budget Tracking)
- 月度/年度预算规划
- 实时追踪
- 交易记录 (Transaction Records)
- 多币种支持
- 分类管理
- 数据统计分析 (Data Analytics)
- 消费模式分析
- 自定义报表

## Project Structure / 项目结构

```
AccountAPI/
├── Sources/
│   └── App/
│       ├── Controllers/     # API 控制器
│       ├── Models/          # 数据模型
│       ├── DTOs/            # 数据传输对象
│       ├── Migrations/      # 数据库迁移
│       ├── Services/        # 业务逻辑服务
│       ├── Middleware/      # 自定义中间件
│       └── Utils/           # 辅助工具
├── Tests/                   # 单元和集成测试
├── Resources/               # 静态资源
└── Docker/                  # Docker 配置
```