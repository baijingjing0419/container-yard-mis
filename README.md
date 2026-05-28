# 集装箱码头堆场管理信息MIS系统

Container Terminal Yard Management Information System

## 项目简介

一套完整的集装箱码头堆场管理信息系统，覆盖海侧(船舶装卸)、陆侧(闸口集卡)、场内(堆存调箱)、中控调度四大业务域，包含 **71 个 RESTful API** 和 **13 个前端页面**。

## 目录结构

```
mis/
├── README.md                          # 本文件
├── .gitignore
├── 数据库设计文档.md                    # 数据库设计文档（中文）
├── yard_mis_database.sql              # MySQL 完整建库脚本（含种子数据）
├── database_er_diagram.png            # 数据库 ER 关系图
│
├── backend/                           # Python FastAPI 后端
│   ├── requirements.txt
│   ├── .env.example
│   └── app/
│       ├── main.py                    # FastAPI 入口
│       ├── core/                      # 配置 + 数据库连接
│       ├── models/                    # SQLAlchemy ORM (16 张表)
│       ├── schemas/                   # Pydantic 数据验证
│       └── api/v1/                    # RESTful API 路由 (17 个模块)
│
└── frontend/                          # Vue 3 + Vite 前端
    ├── package.json
    ├── vite.config.js
    ├── tailwind.config.js
    └── src/
        ├── main.js                    # Vue 入口
        ├── api/                       # Axios 请求层 (10 个模块)
        ├── components/                # 公共组件 (BaseModal, StatusBadge)
        ├── layout/                    # MainLayout (侧边栏+顶栏)
        ├── router/                    # Vue Router (13 条路由)
        └── views/                     # 13 个业务视图
```

## 环境要求

| 组件 | 版本 |
|------|------|
| Python | 3.10+ |
| Node.js | 18+ |
| MySQL | 8.0+ |

## 快速开始

### 1. 初始化数据库

```bash
mysql -u root -p < yard_mis_database.sql
```

这将创建 `ContainerTerminalDB` 数据库，包含 16 张表、3 个视图、4 个存储过程、2 个触发器和预置种子数据（4 艘船舶、3 个堆场区域、4 个用户账号）。

### 2. 启动后端

```bash
cd backend

# 安装依赖
pip install -r requirements.txt

# 配置数据库连接（参考 .env.example）
cp .env.example .env
# 编辑 .env 中的 DB_PASSWORD 为实际密码

# 启动服务
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

后端启动后访问：
- API 文档: http://localhost:8000/docs (Swagger)
- 健康检查: http://localhost:8000/health

### 3. 启动前端

```bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

前端启动后访问: http://localhost:5173

> 前端通过 Vite 代理将 `/api` 请求转发到后端（`http://localhost:8000`），无需单独处理跨域。确保后端在 8000 端口运行。

### 4. 预置账号

| 用户名 | 角色 | 说明 |
|--------|------|------|
| dispatcher | 中控调度员 | 调度中心 |
| gate_clerk | 闸口管理员 | 闸口管理 |
| yard_op | 堆场管理员 | 堆场管理 |
| admin | 系统管理员 | 信息中心 |

## 技术栈

### 后端
- **框架**: FastAPI (异步, 自动 OpenAPI 文档)
- **ORM**: SQLAlchemy 2.0 (异步模式)
- **数据库驱动**: aiomysql (纯 Python, 无需 C 编译)
- **数据验证**: Pydantic v2
- **数据库**: MySQL 8.0 + InnoDB (遵循第三范式)

### 前端
- **框架**: Vue 3 (Composition API + `<script setup>`)
- **构建工具**: Vite 5
- **路由**: Vue Router 4
- **HTTP 客户端**: Axios (拦截器统一错误处理)
- **图表**: Chart.js 4
- **CSS**: Tailwind CSS 3 + 自定义 CSS 变量
- **图标**: Font Awesome 6 (CDN)

### 数据库
- 16 张业务表 + 3 张系统管理表
- 3 个视图 (综合查询 / 今日汇总 / 利用率)
- 4 个存储过程 + 2 个触发器
- 9 个优化索引

## API 模块一览

| 模块 | 端点数 | 前缀 |
|------|--------|------|
| 船舶管理 | 5 | `/api/v1/ships` |
| 堆场区域 | 4 | `/api/v1/yard-zones` |
| 堆场箱位 | 3 | `/api/v1/yard-slots` |
| 海侧进箱 D1 | 5 | `/api/v1/sea-inbounds` |
| 海侧出场 D2 | 4 | `/api/v1/sea-outbounds` |
| 码头统筹 D3 | 4 | `/api/v1/sea-terminal-io` |
| 陆侧进箱 D4 | 4 | `/api/v1/land-inbounds` |
| 陆侧出场 D5 | 4 | `/api/v1/land-outbounds` |
| 闸口通行 D6 | 4 | `/api/v1/gate-records` |
| 场内台账 D7 | 5 | `/api/v1/yard-inventory` |
| 作业记录 D8 | 4 | `/api/v1/yard-operations` |
| 调度指令 D9 | 5 | `/api/v1/dispatch-orders` |
| 海侧计划 | 4 | `/api/v1/sea-plans` |
| 陆侧计划 | 4 | `/api/v1/land-plans` |
| 用户管理 | 4 | `/api/v1/users` |
| 系统日志 | 2 | `/api/v1/system-logs` |
| 异常告警 | 4 | `/api/v1/alerts` |

## 设计文档

- [数据库设计文档](数据库设计文档.md) — 完整表结构、字段说明、过程-数据类矩阵
- [ER 关系图](database_er_diagram.png) — 实体关系图
- [建库脚本](yard_mis_database.sql) — MySQL DDL + 种子数据
