# 个人记账app (BookKeeper)

## 📝 项目介绍

智能记账应用系统是一个基于前后端分离架构的完整记账解决方案，包含iOS客户端和后端API服务。本项目致力于为用户提供简单易用、功能强大的个人财务管理工具。


## 🏗 项目架构

项目采用现代化的前后端分离架构：

- 前端：原生iOS应用，采用SwiftUI框架开发，MVVM架构
- 后端：基于Vapor框架的RESTful API服务
- 数据库：MySQL存储核心数据
- 缓存：Redis用于会话管理和缓存
- 对象存储：MinIO用于存储用户上传的票据图片等资源

## 📦 子项目说明

### AccountBook (iOS客户端)

- 路径：`/AccountBook`
- 描述：原生iOS客户端应用
- 主要功能：用户认证、账单管理、预算追踪、数据统计

### AccountAPI (后端服务)

- 路径：`/AccountAPI`
- 描述：后端API服务
- 主要功能：业务逻辑处理、数据持久化、数据库操作

## 💻 技术栈

### 前端技术栈
- SwiftUI - 用户界面开发
- Swift Charts - 数据可视化
- Combine - 响应式编程
- PhotosUI - 图片选择

### 后端技术栈
- Vapor 4.0 - Web框架
- Fluent - ORM框架
- MySQL 8.0 - 数据库

## ⭐️ 功能特点

- 📊 可视化的收支统计
- 📅 多维度的预算管理
- 🔄 自动数据同步
- 📱 离线功能支持

## 🚀 部署说明

### 环境要求

- macOS 12.0+（开发环境）
- Xcode 14.0+
- Docker（后端部署）
- MySQL 8.0+

### 环境配置

1. 安装MySQL
```bash
brew install mysql
```

2. 创建数据库
```bash
mysql -u root -p
CREATE DATABASE account_book;
```

3. 安装Swift
```bash
brew install swift
```

### 后端部署步骤

1. 克隆仓库
```bash
git clone https://github.com/MegumiKato23/BookKeeper.git
```

2. 配置数据库
```bash
cd AccountAPI/Sources/App
vim configure.swift
# 修改数据库配置
```

3. 运行服务
```bash
swift run
```

### iOS应用构建

1. 安装依赖
```bash
cd AccountBook
pod install
```

2. 打开Xcode项目
```bash
open AccountBook.xcworkspace
```

3. 配置开发者证书和配置文件
4. 构建和运行项目
