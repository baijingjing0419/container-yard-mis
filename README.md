# 集装箱码头堆场管理信息MIS系统

Container Terminal Yard Management Information System

## 项目简介

一套完整的集装箱码头堆场管理信息系统，覆盖海侧(船舶装卸)、陆侧(闸口集卡)、场内(堆存调箱)、中控调度四大业务域，包含 **71 个 RESTful API** 和 **13 个前端页面**。

## 目录结构

```
mis/
├── README.md
├── .gitignore
├── docker-compose.yml                 # 生产环境 Docker 编排
├── docker-compose.dev.yml             # 开发环境 (热重载)
├── 数据库设计文档.md
├── yard_mis_database.sql              # MySQL 完整建库脚本（含种子数据）
├── database_er_diagram.png            # 数据库 ER 关系图
│
├── backend/                           # Python FastAPI 后端
│   ├── Dockerfile                     # 生产镜像
│   ├── .dockerignore
│   ├── requirements.txt
│   ├── .env.example
│   └── app/
│       ├── main.py                    # FastAPI 入口
│       ├── core/                      # 配置 + 异步数据库连接
│       ├── models/                    # SQLAlchemy ORM (16 张表, 含索引)
│       ├── schemas/                   # Pydantic 数据验证
│       └── api/v1/                    # RESTful API 路由 (17 个模块)
│
└── frontend/                          # Vue 3 + Vite 前端
    ├── Dockerfile                     # 生产镜像 (Nginx)
    ├── Dockerfile.dev                 # 开发镜像 (Vite dev server)
    ├── nginx.conf                     # Nginx 反向代理配置
    ├── .dockerignore
    ├── package.json
    ├── tsconfig.json                  # TypeScript 配置
    ├── vite.config.js                 # Vite + API 代理 (环境变量)
    ├── tailwind.config.js
    └── src/
        ├── main.ts                    # Vue 入口 (Pinia 注册)
        ├── env.d.ts                   # TypeScript 类型声明
        ├── constants.ts               # 统一状态映射常量
        ├── api/                       # Axios 请求层 (全部 .ts)
        ├── store/                     # Pinia 状态管理 (user + app + toast)
        ├── components/                # 公共组件 (BaseModal, StatusBadge)
        ├── layout/                    # MainLayout (侧边栏+顶栏+Toast)
        ├── router/                    # Vue Router (懒加载)
        └── views/                     # 13 个业务视图 (虚拟滚动 + API 驱动)
```

## 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| Python | 3.10+ | 本地开发必需 |
| Node.js | 18+ | 本地开发必需 |
| MySQL | 8.0+ | 本地开发必需 |
| Docker | 24+ | 容器化部署 (可选) |

## 快速开始

### 方式一：Docker 一键部署（推荐）

```bash
# 生产模式
docker compose up -d --build

# 开发模式（代码热重载，无需重建镜像）
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
```

| 模式 | 前端地址 | 后端地址 | 热重载 |
|------|----------|----------|:--:|
| 生产 | http://localhost:8080 | http://localhost:8000/docs | - |
| 开发 | http://localhost:5173 | http://localhost:8000/docs | 是 |

### 方式二：本地开发

#### 1. 初始化数据库

```bash
mysql -u root -p < yard_mis_database.sql
```

这将创建 `ContainerTerminalDB` 数据库，包含 16 张表、3 个视图、4 个存储过程、2 个触发器和预置种子数据（4 艘船舶、3 个堆场区域、4 个用户账号）。

#### 2. 启动后端

```bash
cd backend

# 创建并激活虚拟环境 (推荐)
python -m venv .venv
.venv\Scripts\activate     # Windows
# source .venv/bin/activate  # macOS / Linux

# 安装依赖
pip install -r requirements.txt

# 配置数据库连接
cp .env.example .env
# 编辑 .env，修改 DB_PASSWORD 为实际密码

# 启动服务
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

后端启动后访问：
- API 文档: http://localhost:8000/docs (Swagger)
- 健康检查: http://localhost:8000/health

#### 3. 启动前端

```bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

前端启动后访问: http://localhost:5173

> 前端通过 Vite 代理将 `/api` 请求转发到后端 `http://localhost:8000`，无需单独处理跨域。

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
- **ORM**: SQLAlchemy 2.0 (异步引擎 + async/await)
- **数据库驱动**: aiomysql (纯 Python, 无需 C 编译)
- **数据验证**: Pydantic v2 + pydantic-settings
- **数据库**: MySQL 8.0 + InnoDB (遵循第三范式)
- **性能**: 14 个查询索引 + 分页 + 异步连接池

### 前端
- **框架**: Vue 3 (Composition API + `<script setup>`)
- **状态管理**: Pinia (user / app / toast 通知)
- **类型支持**: TypeScript (API 层 + Store 层全部迁移)
- **构建工具**: Vite 5 (API 代理 + 热更新 + 环境变量)
- **路由**: Vue Router 4 (全部懒加载)
- **性能**: @vueuse/core 虚拟滚动 (千级数据无卡顿)
- **HTTP 客户端**: Axios (拦截器统一错误处理)
- **图表**: Chart.js 4 (动态数据驱动)
- **通知**: Toast 通知系统 (替代 alert 弹窗)
- **CSS**: Tailwind CSS 3 + 自定义 CSS 变量
- **图标**: Font Awesome 6 (CDN)

### DevOps
- **容器化**: Docker + docker compose
- **前端部署**: Nginx 反向代理
- **开发体验**: 热重载 + HMR + 虚拟环境

### 数据库
- 16 张业务表 + 3 张系统管理表
- 3 个视图 (综合查询 / 今日汇总 / 利用率)
- 4 个存储过程 + 2 个触发器
- 14 个查询优化索引

## 页面功能

| 页面 | 路由 | 核心功能 |
|------|------|----------|
| 运营总览 | `/dashboard` | 6 个实时统计卡片 + 24h 趋势图 + 堆场状态图 + 告警时间线 |
| 海侧进箱 | `/sea/inbound` | 卸船入场全流程管理，动态显示当前作业计划 |
| 海侧出场 | `/sea/outbound` | 装船出场全流程管理，动态显示当前作业计划 |
| 海侧计划 | `/sea/plan` | 海侧作业计划编排与管理 |
| 陆侧进箱 | `/land/inbound` | 集卡进闸全流程，实时闸口通行统计 |
| 陆侧出场 | `/land/outbound` | 集卡出闸提箱管理 |
| 陆侧计划 | `/land/plan` | 陆侧作业计划编排与管理 |
| 堆存管理 | `/yard/storage` | 集装箱台账 + 堆场区域利用率 (虚拟滚动) |
| 调箱作业 | `/yard/move` | 场内翻箱/归位作业管理 |
| 调度指令 | `/dispatch` | 中控调度指令下发与执行追踪 (虚拟滚动) |
| 箱量查询 | `/query` | 按箱号/船名/堆位多维度查询 (虚拟滚动) |
| 效率统计 | `/statistics` | 班组效率 + 月度趋势 + 设备利用率 (动态图表) |
| 报表中心 | `/reports` | 系统日志与报表历史查看 |

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
