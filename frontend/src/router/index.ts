import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import MainLayout from '../layout/MainLayout.vue'
import { useUserStore, getDefaultRoute } from '../store/user'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login/index.vue'),
    meta: { title: '登录', public: true },
  },
  {
    path: '/',
    component: MainLayout,
    redirect: '/dashboard',
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('../views/Dashboard/index.vue'), meta: { title: '运营总览', roles: ['admin', 'dispatcher'] } },
      { path: 'sea/inbound', name: 'SeaInbound', component: () => import('../views/SeaInbound/index.vue'), meta: { title: '海侧进箱作业', roles: ['admin', 'qc_op', 'yc_op'] } },
      { path: 'sea/outbound', name: 'SeaOutbound', component: () => import('../views/SeaOutbound/index.vue'), meta: { title: '海侧出场作业', roles: ['admin', 'qc_op', 'yc_op'] } },
      { path: 'sea/plan', name: 'SeaPlan', component: () => import('../views/SeaPlan/index.vue'), meta: { title: '海侧作业计划', roles: ['admin', 'dispatcher'] } },
      { path: 'land/inbound', name: 'LandInbound', component: () => import('../views/LandInbound/index.vue'), meta: { title: '陆侧进箱作业', roles: ['admin', 'gate_clerk', 'yc_op'] } },
      { path: 'land/outbound', name: 'LandOutbound', component: () => import('../views/LandOutbound/index.vue'), meta: { title: '陆侧出场作业', roles: ['admin', 'gate_clerk', 'yc_op'] } },
      { path: 'land/plan', name: 'LandPlan', component: () => import('../views/LandPlan/index.vue'), meta: { title: '陆侧作业计划', roles: ['admin', 'gate_clerk', 'dispatcher'] } },
      { path: 'yard/storage', name: 'YardStorage', component: () => import('../views/YardStorage/index.vue'), meta: { title: '集装箱堆存管理', roles: ['admin', 'dispatcher', 'yc_op'] } },
      { path: 'yard/move', name: 'YardMove', component: () => import('../views/YardMove/index.vue'), meta: { title: '场内调箱作业', roles: ['admin', 'yc_op'] } },
      { path: 'dispatch', name: 'Dispatch', component: () => import('../views/Dispatch/index.vue'), meta: { title: '中控调度指令', roles: ['admin', 'dispatcher', 'qc_op', 'yc_op'] } },
      { path: 'query', name: 'Query', component: () => import('../views/Query/index.vue'), meta: { title: '箱量/状态查询', roles: ['admin', 'dispatcher', 'gate_clerk', 'qc_op', 'yc_op'] } },
      { path: 'statistics', name: 'Statistics', component: () => import('../views/Statistics/index.vue'), meta: { title: '作业效率统计', roles: ['admin', 'dispatcher'] } },

    ],
  },
]

const router = createRouter({ history: createWebHistory(), routes })

router.beforeEach(async (to, _from, next) => {
  if (to.meta?.public) { next(); return }

  const userStore = useUserStore()
  if (!userStore.loggedIn) {
    userStore.restoreSession()
    if (!userStore.loggedIn) {
      next('/login')
      return
    }
  }

  const allowedRoles = to.meta?.roles as string[] | undefined
  if (allowedRoles && allowedRoles.length > 0 && !allowedRoles.includes(userStore.role)) {
    const defaultPath = getDefaultRoute(userStore.role)
    if (to.path === defaultPath) {
      userStore.logout()
      next('/login')
      return
    }
    next(defaultPath)
    return
  }

  next()
})

export default router
