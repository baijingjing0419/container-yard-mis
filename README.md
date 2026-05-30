# 集装箱码头堆场管理信息系统 (Container Yard MIS)

一套完整的集装箱码头堆场管理信息系统，覆盖海侧（船舶装卸）、陆侧（闸口集卡）、场内（堆存调箱）、中控调度四大业务域。采用前后端分离架构，含 **18 个 API 模块、78 个 RESTful 端点、14 个前端页面**。

---

## 目录

- [页面功能概览](#页面功能概览)
- [目录结构](#目录结构)
- [环境要求](#环境要求)
- [快速开始](#快速开始)
- [技术栈](#技术栈)
- [数据库架构](#数据库架构)
- [API 模块一览](#api-模块一览)
- [认证与登录](#认证与登录)
- [开发指南](#开发指南)
- [设计文档](#设计文档)

---

## 页面功能概览

| 页面 | 路由 | 核心功能 |
|------|------|----------|
| **登录** | `/login` | 工号+密码登录（PBKDF2 哈希），JWT 认证，开发者免登入口 |
| **运营总览** | `/dashboard` | 6 个实时统计卡片 + 24h 作业趋势图 + 堆场热力图 + 告警时间线 |
| **海侧进箱** | `/sea/inbound` | 卸船入场全流程，动态显示当前作业计划（主数据优先校验） |
| **海侧出场** | `/sea/outbound` | 装船出场全流程，动态显示当前作业计划 |
| **海侧计划** | `/sea/plan` | 海侧作业计划编排与管理 |
| **陆侧进箱** | `/land/inbound` | 集卡进闸全流程，实时闸口通行统计 |
| **陆侧出场** | `/land/outbound` | 集卡出闸提箱管理 |
| **陆侧计划** | `/land/plan` | 陆侧作业计划编排与管理 |
| **堆存管理** | `/yard/storage` | 集装箱台账 + 区域利用率 + **导轨查询（虚拟滚动）** |
| **调箱作业** | `/yard/move` | 场内翻箱/归位，**409 乐观锁冲突自动提示** |
| **调度指令** | `/dispatch` | 中控调度指令下发与执行追踪（虚拟滚动） |
| **箱量查询** | `/query` | 按箱号/船名/堆位多维度查询（虚拟滚动） |
| **效率统计** | `/statistics` | 班组效率 + 月度趋势 + 设备利用率（全动态图表） |
| **报表中心** | `/reports` | 系统日志与报表历史查看 |

---

## 目录结构

```
mis/
├── README.md
├── .gitignore
├── docker-compose.yml                 # 生产环境 Docker 编排（MySQL + Backend + Frontend）
├── docker-compose.dev.yml             # 开发环境覆盖（代码挂载 + 热重载）
├── tests/
│   └── test_optimistic_lock.py        # 乐观锁并发压测脚本
├── database/
│   ├── schema.sql                      # 全量建库脚本（始终最新版本）
│   ├── database_er_diagram.png         # 数据库 ER 关系图
│   ├── migrations/                     # 增量迁移脚本
│   │   ├── 001_optimize_v2.sql         # V2 架构升级（主数据表 + 乐观锁 + 分区）
│   │   ├── 002_drop_occupied_slots.sql # V3 移除反范式字段
│   │   └── 003_partition_maintenance.sql # 分区自动维护
│   └── seeds/                          # 测试种子数据
│       ├── dev_seed.sql                # V2 架构测试数据
│       └── cleanup_test_data.sql       # 清理测试数据
├── docs/
│   └── 数据库设计文档.md
│
├── backend/                           # Python FastAPI 后端
│   ├── Dockerfile                     # 生产镜像（python:3.12-slim）
│   ├── .dockerignore
│   ├── .env.example                   # 环境变量模板（含 Docker 变量说明）
│   ├── requirements.txt               # Python 依赖清单
│   └── app/
│       ├── main.py                    # FastAPI 入口（CORS + 生命周期管理）
│       ├── core/
│       │   ├── config.py              # pydantic-settings 配置中心（含 JWT 配置）
│       │   ├── database.py            # SQLAlchemy 2.0 异步引擎 + 会话管理
│       │   └── security.py            # ★ PBKDF2 密码哈希/验证（新增）
│       ├── models/                    # 19 个 ORM 模型（含 V2 主数据表 + 流水表）
│       ├── schemas/                   # Pydantic v2 数据验证（含 V2 新 Schema）
│       └── api/
│           ├── deps.py                # ★ JWT 认证 + RBAC 依赖注入（新增）
│           └── v1/                    # 18 个 API 路由模块
│               ├── router.py          # 路由聚合器
│               ├── auth.py            # ★ 登录认证 + JWT 签发（重构）
│               ├── containers.py      # ★ 集装箱主数据 + 轨迹查询（新增）
│           ├── ships.py               # 船舶管理
│           ├── yard_zones.py          # 堆场区域
│           ├── yard_slots.py          # 箱位管理
│           ├── yard_container_inventory.py   # 场内台账
│           ├── yard_operation_records.py     # 作业记录（含乐观锁）
│           ├── dispatch_orders.py            # 调度指令
│           ├── sea_inbound_containers.py     # 海侧进箱（含主数据优先）
│           ├── sea_outbound_containers.py    # 海侧出场
│           ├── sea_terminal_io.py            # 码头统筹
│           ├── sea_operation_plans.py        # 海侧计划
│           ├── land_inbound_containers.py    # 陆侧进箱
│           ├── land_outbound_containers.py   # 陆侧出场
│           ├── land_operation_plans.py       # 陆侧计划
│           ├── gate_io_records.py            # 闸口通行
│           ├── users.py                      # 用户管理
│           ├── system_logs.py                # 系统日志
│           └── alerts.py                     # 异常告警
│
└── frontend/                          # Vue 3 + Vite + TypeScript 前端
    ├── Dockerfile                     # 生产镜像（Node 构建 + Nginx 部署）
    ├── Dockerfile.dev                 # 开发镜像（Vite dev server）
    ├── nginx.conf                     # Nginx 反向代理 /api → backend:8000
    ├── .dockerignore
    ├── index.html
    ├── package.json
    ├── tsconfig.json / tsconfig.node.json
    ├── vite.config.js                 # Vite + API 代理（VITE_API_TARGET 环境变量）
    ├── tailwind.config.js
    └── src/
        ├── main.ts                    # Vue 入口（Pinia + Router + Toast 全局挂载）
        ├── App.vue
        ├── env.d.ts                   # Vue SFC 类型声明
        ├── types.ts                   # 业务类型定义（ContainerMaster, MoveLog 等）
        ├── constants.ts               # 状态映射常量
        ├── index.css                  # Tailwind + 全局样式
        ├── api/                       # Axios 请求层（全部 .ts）
        │   ├── request.ts             # Axios 实例 + 409 拦截 + 错误处理
        │   ├── container.ts           # ★ 集装箱主数据 + 轨迹 API
        │   ├── dispatchOrder.ts       # 调度指令
        │   ├── landInbound.ts         # 陆侧进箱
        │   ├── landOutbound.ts        # 陆侧出场
        │   ├── landPlan.ts            # 陆侧计划
        │   ├── seaInbound.ts          # 海侧进箱
        │   ├── seaOutbound.ts         # 海侧出场
        │   ├── seaPlan.ts             # 海侧计划
        │   ├── yardInventory.ts       # 场内台账
        │   └── yardOperation.ts       # 作业记录
        ├── store/                     # Pinia 状态管理
        │   ├── app.ts                 # 通知 + Toast + 侧边栏
        │   └── user.ts                # 用户登录/登出/会话恢复
        ├── layout/
        │   └── MainLayout.vue         # 侧边栏 + 顶栏 + Toast + 通知面板
        ├── router/
        │   └── index.ts               # Vue Router（懒加载 + 鉴权守卫）
        ├── components/
        │   ├── BaseModal.vue          # 通用模态框
        │   └── StatusBadge.vue        # 状态徽章
        └── views/
            ├── Login/index.vue        # ★ 登录页
            ├── Dashboard/index.vue    # 运营总览
            ├── SeaInbound/index.vue   # 海侧进箱
            ├── SeaOutbound/index.vue  # 海侧出场
            ├── SeaPlan/index.vue      # 海侧计划
            ├── LandInbound/index.vue  # 陆侧进箱
            ├── LandOutbound/index.vue # 陆侧出场
            ├── LandPlan/index.vue     # 陆侧计划
            ├── YardStorage/index.vue  # 堆存管理（虚拟滚动 + 导轨弹窗）
            ├── YardMove/index.vue     # 调箱作业
            ├── Dispatch/index.vue     # 调度指令（虚拟滚动）
            ├── Query/index.vue        # 箱量查询（虚拟滚动）
            ├── Statistics/index.vue   # 效率统计（全动态图表）
            └── Reports/index.vue      # 报表中心
```

---

## 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| Python | 3.10+ | 本地开发必需 |
| Node.js | 18+ | 本地开发必需 |
| MySQL | 8.0+ | 本地开发必需 |
| Docker | 24+ | 容器化部署（可选，推荐） |

---

## 快速开始

### 方式一：Docker 一键部署（推荐）

```bash
# 生产模式（Nginx 部署静态文件，端口 8080）
docker compose up -d --build

# 开发模式（代码挂载 + 热重载，端口 5173）
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
```

| 模式 | 前端地址 | 后端 API 文档 | 数据库端口 | 热重载 |
|------|----------|---------------|:--:|:--:|
| 生产 | http://localhost:8080 | http://localhost:8000/docs | 3307 | -- |
| 开发 | http://localhost:5173 | http://localhost:8000/docs | 3307 | 是 |

> **生产模式**：前端由 Nginx 部署静态文件并反向代理 `/api` 到后端，无需 CORS。  
> **开发模式**：前端 Vite dev server 直接代理到后端（使用 `VITE_API_TARGET` 环境变量），代码修改即时生效。

### 方式二：本地开发

#### 1. 初始化数据库

```bash
# 新环境：全量建库
mysql -u root -p < database/schema.sql

# 已有数据库：增量升级
docker exec -i yard-mysql mysql -u root -proot ContainerTerminalDB < database/migrations/001_optimize_v2.sql
```

这将创建 `ContainerTerminalDB` 数据库，包含 21 张表、3 个视图、4 个存储过程、2 个触发器和预置种子数据。

#### 2. 启动后端

```bash
cd backend

# 创建并激活虚拟环境
python -m venv .venv
source .venv/bin/activate   # macOS / Linux
.venv\Scripts\activate      # Windows

# 安装依赖
pip install -r requirements.txt

# 配置环境变量（复制并编辑）
cp .env.example .env
# 编辑 .env 中的 DB_PASSWORD 为实际 MySQL 密码

# 启动服务
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

后端启动后访问：
- Swagger API 文档: http://localhost:8000/docs
- 健康检查: http://localhost:8000/health

#### 3. 启动前端

```bash
cd frontend

npm install
npm run dev
```

启动后访问 http://localhost:5173 ，会自动跳转到登录页。

> 前端通过 Vite 代理将 `/api` 请求转发到后端 `http://localhost:8000`。

---

## 技术栈

### 后端
| 类别 | 技术 | 说明 |
|------|------|------|
| 框架 | FastAPI | 异步 Web 框架，自动生成 OpenAPI 文档 |
| ORM | SQLAlchemy 2.0 | 异步引擎（async/await）+ 声明式映射 |
| 数据库驱动 | aiomysql + cryptography | 纯 Python MySQL 异步驱动，支持 caching_sha2_password |
| 数据验证 | Pydantic v2 + pydantic-settings | Schema 校验 + 环境变量管理 |
| 数据库 | MySQL 8.0 + InnoDB | 遵循第三范式，含 14 个查询索引 |
| 认证 | JWT (python-jose) + PBKDF2 | Bearer Token 认证，密码哈希存储 |
| 权限 | RoleChecker 依赖注入 | 闭包高阶函数，角色级 API 访问控制 |
| 并发控制 | 乐观锁 (version 字段) | 高并发箱位预占防超卖，max 3 次重试 |
| 冷热分离 | 表分区 (RANGE BY TO_DAYS) | 3 张日志表按月分区 |

### 前端
| 类别 | 技术 | 说明 |
|------|------|------|
| 框架 | Vue 3 | Composition API + `<script setup>` |
| 状态管理 | Pinia | user（登录态）+ app（Toast 通知） |
| 类型 | TypeScript | API 层 + Store 层全部迁移 |
| 构建 | Vite 5 | 代理 + 热更新 + 环境变量 |
| 路由 | Vue Router 4 | 懒加载 + beforeEach RBAC 守卫（角色-路由矩阵） |
| 性能 | @vueuse/core | 虚拟滚动（千级数据无卡顿） |
| HTTP | Axios | 请求拦截器自动携带 JWT + 409 乐观锁拦截 + 统一错误 Toast |
| 图表 | Chart.js 4 | 全动态数据驱动（无 Mock） |
| 通知 | Toast 系统 | 3 秒自动消失，success/error/info 三色 |
| CSS | Tailwind CSS 3 | 实用优先 + 自定义设计令牌 |
| 图标 | Font Awesome 6 | CDN 加载 |

### DevOps
| 类别 | 技术 | 说明 |
|------|------|------|
| 容器化 | Docker + docker compose | 三容器编排（MySQL + Backend + Frontend） |
| 前端部署 | Nginx | SPA 静态文件 + API 反向代理 |
| 开发体验 | 热重载 + HMR | uvicorn --reload + Vite dev server |
| 环境隔离 | Python venv + Docker | 虚拟环境 + 容器隔离 |
| 测试 | Python httpx + asyncio | 乐观锁并发压测 |

---

## 数据库架构

### V2.0 架构升级要点

| 优化项 | 说明 |
|--------|------|
| **containers_master** | 集装箱主数据表，解耦 D1/D2/D4/D5/D7 的循环依赖。陆侧箱可独立入账 |
| **container_move_logs** | 箱位移动流水表，替代 JSON 文本字段。支持结构化轨迹追溯和时间范围索引 |
| **乐观锁** | `yard_slots.version INT DEFAULT 0`，UPDATE 时对比版本号，防高并发超卖 |
| **表分区** | `system_logs` / `gate_io_records` / `yard_operation_records` 按月 RANGE 分区 |

### 表结构总览（21 张表）

```
ContainerTerminalDB
├── 主数据表
│   └── containers_master          # 集装箱主数据（固有物理属性）
│
├── 基础支撑表 (3)
│   ├── ships                      # 船舶信息
│   ├── yard_zones                 # 堆场区域
│   └── yard_slots                 # 箱位明细（含 version 乐观锁）
│
├── 业务数据表 (14)
│   ├── sea_inbound_containers     # D1 海侧进箱
│   ├── sea_outbound_containers    # D2 海侧出场
│   ├── sea_terminal_io            # D3 码头统筹
│   ├── sea_operation_plans        # 海侧计划
│   ├── land_inbound_containers    # D4 陆侧进箱
│   ├── land_outbound_containers   # D5 陆侧出场
│   ├── land_operation_plans       # 陆侧计划
│   ├── gate_io_records            # D6 闸口通行
│   ├── yard_container_inventory   # D7 场内台账
│   ├── yard_operation_records     # D8 作业记录
│   ├── dispatch_orders            # D9 调度指令
│   ├── users                      # 用户权限
│   ├── system_logs                # 操作日志（按月分区）
│   └── alerts                     # 异常告警
│
└── 流水日志表
    └── container_move_logs        # 箱位移动流水（按月分区）
```

### 关键外键关系

```
containers_master.container_id ──→ sea_inbound_containers.container_id
                                ├→ sea_outbound_containers.container_id
                                ├→ land_inbound_containers.container_id
                                ├→ land_outbound_containers.container_id
                                ├→ yard_container_inventory.container_id
                                ├→ yard_operation_records.container_id
                                ├→ dispatch_orders.container_id
                                ├→ gate_io_records.container_id
                                └→ container_move_logs.container_id

yard_slots.slot_id ──→ container_move_logs.from_slot_id
                    ├→ container_move_logs.to_slot_id
                    ├→ yard_container_inventory.current_slot_id
                    └→ yard_operation_records.original/target_slot_id
```

---

## API 模块一览

| 模块 | 端点 | 前缀 | 说明 |
|------|:--:|------|------|
| 认证 | 1 | `/api/v1/auth` | ★ JWT 登录认证，PBKDF2 验密（重构） |
| 集装箱主数据 | 3 | `/api/v1/containers` | ★ 主数据 CRUD + 轨迹查询（新增） |
| 船舶管理 | 5 | `/api/v1/ships` | 船舶 CRUD |
| 堆场区域 | 4 | `/api/v1/yard-zones` | 区域查询与利用率 |
| 堆场箱位 | 3 | `/api/v1/yard-slots` | 箱位管理（含乐观锁） |
| 海侧进箱 D1 | 5 | `/api/v1/sea-inbounds` | 含主数据优先校验 |
| 海侧出场 D2 | 4 | `/api/v1/sea-outbounds` | 装船出场 |
| 码头统筹 D3 | 4 | `/api/v1/sea-terminal-io` | 码头出入统筹 |
| 陆侧进箱 D4 | 4 | `/api/v1/land-inbounds` | 陆侧入场 |
| 陆侧出场 D5 | 4 | `/api/v1/land-outbounds` | 陆侧出场 |
| 闸口通行 D6 | 4 | `/api/v1/gate-records` | 闸口出入 |
| 场内台账 D7 | 5 | `/api/v1/yard-inventory` | 场内集装箱全生命周期 |
| 作业记录 D8 | 4 | `/api/v1/yard-operations` | 含乐观锁 + 轨迹同步 |
| 调度指令 D9 | 5 | `/api/v1/dispatch-orders` | ★ POST 受 RBAC 保护（admin+dispatcher） |
| 海侧计划 | 4 | `/api/v1/sea-plans` | 作业计划 |
| 陆侧计划 | 4 | `/api/v1/land-plans` | 作业计划 |
| 用户管理 | 4 | `/api/v1/users` | ★ POST + PUT status 受 RBAC 保护（admin） |
| 系统日志 | 2 | `/api/v1/system-logs` | 操作日志 |
| 异常告警 | 4 | `/api/v1/alerts` | 告警管理 |

**合计：18 个模块，78 个端点**

---

## 认证与登录

### 登录方式

输入**工号 + 密码**登录，后端采用 **PBKDF2-HMAC-SHA256**（10 万次迭代）哈希存储密码，登录成功后签发 **JWT**（8 小时有效），前端自动在后续请求中携带 `Authorization: Bearer` 头。

登录页面底部设有 **「开发者入口」** 按钮，点击后跳过认证直接以管理员身份进入主界面，方便开发调试。

### 预置账号

| 工号 | 用户名 | 姓名 | 角色 | 部门 | 密码 |
|------|--------|------|------|------|------|
| `1` | dispatcher | 李明 | 中控调度员 | 调度中心 | `123` |
| `2` | gate_clerk | 王芳 | 闸口管理员 | 闸口管理 | `123` |
| `3` | qc_op | 赵岸 | 岸桥操作员 | 岸桥班组 | `123` |
| `4` | yc_op | 钱场 | 场桥操作员 | 场桥班组 | `123` |
| `5` | admin | 管理员 | 系统管理员 | 信息中心 | `123` |

### 登录流程

1. 访问任意页面 → 未登录 → 自动跳转 `/login`
2. 输入工号 + 密码 → 点击登录
3. 后端 `POST /api/v1/auth/login` 校验工号存在性、账号状态、密码正确性
4. 成功 → 返回 JWT → Pinia store 保存用户信息 + localStorage 持久化 → 按角色重定向到高频页
5. 后续请求自动携带 `Authorization: Bearer <token>` 头
6. 右上角退出按钮 → 清除会话 + token → 返回登录页

### 认证架构

```
前端                                   后端
┌──────────┐    POST /auth/login     ┌──────────────┐
│  Login   │ ──{user_id, password}──→│  auth.py     │
│  Page    │ ←──{user + JWT}──────   │  PBKDF2 验密  │
└──────────┘                         │  签发 JWT     │
     │                               └──────────────┘
     │ 存储 token
     ▼
┌──────────┐  Authorization: Bearer  ┌──────────────┐
│  Axios   │ ────{JWT token}───────→│  deps.py     │
│intercept.│                         │  get_current │
└──────────┘                         │  _user()     │
                                     │  RoleChecker │
                                     └──────────────┘
                                           │
                                     ┌──────▼───────┐
                                     │ 受保护 API    │
                                     │ (POST /users │
                                     │  仅 admin)   │
                                     └──────────────┘
```

---

## RBAC 权限控制

系统包含 **5 种角色**，前后端双重权限控制：

### 前端 — 路由拦截 + 侧边栏过滤

- 每个路由 `meta.roles` 声明允许访问的角色
- `beforeEach` 守卫拦截越权导航并重定向到用户默认页
- 侧边栏通过 O(1) `hasPermission()` 按需渲染菜单项和分类标题
- 登录后按角色重定向到高频操作页

### 后端 — API 权限校验

- `get_current_user` 从 JWT 提取用户身份
- `RoleChecker(allowed_roles)` 闭包依赖注入，拦截无权请求返回 403
- 已保护端点：

| 端点 | 方法 | 允许角色 |
|------|------|----------|
| `/api/v1/users` | POST | admin |
| `/api/v1/users/{id}/status` | PUT | admin |
| `/api/v1/dispatch-orders` | POST | admin, dispatcher |

### 角色-路由权限矩阵

| 路由 | admin(5) | dispatcher(1) | gate_clerk(2) | qc_op(3) | yc_op(4) |
|------|:--------:|:-------------:|:-------------:|:--------:|:--------:|
| `/dashboard` | Y | Y | - | - | - |
| `/sea/inbound` | Y | - | - | Y | Y |
| `/sea/outbound` | Y | - | - | Y | Y |
| `/sea/plan` | Y | Y | - | - | - |
| `/land/inbound` | Y | - | Y | - | Y |
| `/land/outbound` | Y | - | Y | - | Y |
| `/land/plan` | Y | Y | Y | - | - |
| `/yard/storage` | Y | Y | - | - | Y |
| `/yard/move` | Y | - | - | - | Y |
| `/dispatch` | Y | Y | - | Y | Y |
| `/query` | Y | Y | Y | Y | Y |
| `/statistics` | Y | Y | - | - | - |
| `/reports` | Y | - | - | - | - |

> 登录重定向：admin→/dashboard，dispatcher→/dispatch，gate_clerk→/land/inbound，qc_op→/sea/inbound，yc_op→/yard/move

---

## 开发指南

### 数据库操作

```bash
# 新环境：导入全量建库脚本（始终最新版本）
docker exec -i yard-mysql mysql -u root -proot ContainerTerminalDB < database/schema.sql

# 已有数据库：按顺序执行增量迁移
docker exec -i yard-mysql mysql -u root -proot ContainerTerminalDB < database/migrations/001_optimize_v2.sql
docker exec -i yard-mysql mysql -u root -proot ContainerTerminalDB < database/migrations/002_drop_occupied_slots.sql
docker exec -i yard-mysql mysql -u root -proot ContainerTerminalDB < database/migrations/003_partition_maintenance.sql

# 导入测试种子数据
docker exec -i yard-mysql mysql -u root -proot ContainerTerminalDB < database/seeds/dev_seed.sql

# 清理测试数据（保留基础参考数据）
docker exec -i yard-mysql mysql -u root -proot ContainerTerminalDB < database/seeds/cleanup_test_data.sql
```

### 乐观锁压测

```bash
pip install httpx
python tests/test_optimistic_lock.py
# 期望结果: 10 并发抢占同一箱位 → 1 成功 (200) + 9 冲突 (409)
```

### 代码构建

```bash
# 前端生产构建
cd frontend && npm run build    # 输出到 dist/

# 前端开发服务器
cd frontend && npm run dev      # http://localhost:5173

# 后端开发服务器
cd backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Git 分支规范

```
main ← feat/db-architecture-optimization   (DB V2 架构升级)
    ← feat/api-logic-refactoring           (API 层对齐)
    ← feat/frontend-v2-integration         (前端对接 + 压测)
```

---

## 设计文档

| 文档 | 说明 |
|------|------|
| [数据库设计文档](docs/数据库设计文档.md) | 完整 21 张表结构、字段说明、过程-数据类矩阵、V2 架构变动 |
| [ER 关系图](database/database_er_diagram.png) | 实体关系图 |
| [schema.sql](database/schema.sql) | 全量建库脚本（始终最新版本） |
| [001_optimize_v2.sql](database/migrations/001_optimize_v2.sql) | 迁移：V2 架构升级（主数据表 + 乐观锁 + 分区） |
| [002_drop_occupied_slots.sql](database/migrations/002_drop_occupied_slots.sql) | 迁移：移除反范式字段 |
| [003_partition_maintenance.sql](database/migrations/003_partition_maintenance.sql) | 迁移：分区自动维护 |
| [dev_seed.sql](database/seeds/dev_seed.sql) | 测试种子数据（含轨迹流水） |
| [cleanup_test_data.sql](database/seeds/cleanup_test_data.sql) | 清理测试数据脚本 |
| [test_optimistic_lock.py](tests/test_optimistic_lock.py) | 乐观锁并发压测脚本 |
