import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import MainLayout from '../layout/MainLayout.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: MainLayout,
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('../views/Dashboard/index.vue'),
        meta: { title: '运营总览' },
      },
      {
        path: 'sea/inbound',
        name: 'SeaInbound',
        component: () => import('../views/SeaInbound/index.vue'),
        meta: { title: '海侧进箱作业' },
      },
      {
        path: 'sea/outbound',
        name: 'SeaOutbound',
        component: () => import('../views/SeaOutbound/index.vue'),
        meta: { title: '海侧出场作业' },
      },
      {
        path: 'sea/plan',
        name: 'SeaPlan',
        component: () => import('../views/SeaPlan/index.vue'),
        meta: { title: '海侧作业计划' },
      },
      {
        path: 'land/inbound',
        name: 'LandInbound',
        component: () => import('../views/LandInbound/index.vue'),
        meta: { title: '陆侧进箱作业' },
      },
      {
        path: 'land/outbound',
        name: 'LandOutbound',
        component: () => import('../views/LandOutbound/index.vue'),
        meta: { title: '陆侧出场作业' },
      },
      {
        path: 'land/plan',
        name: 'LandPlan',
        component: () => import('../views/LandPlan/index.vue'),
        meta: { title: '陆侧作业计划' },
      },
      {
        path: 'yard/storage',
        name: 'YardStorage',
        component: () => import('../views/YardStorage/index.vue'),
        meta: { title: '集装箱堆存管理' },
      },
      {
        path: 'yard/move',
        name: 'YardMove',
        component: () => import('../views/YardMove/index.vue'),
        meta: { title: '场内调箱作业' },
      },
      {
        path: 'dispatch',
        name: 'Dispatch',
        component: () => import('../views/Dispatch/index.vue'),
        meta: { title: '中控调度指令' },
      },
      {
        path: 'query',
        name: 'Query',
        component: () => import('../views/Query/index.vue'),
        meta: { title: '箱量/状态查询' },
      },
      {
        path: 'statistics',
        name: 'Statistics',
        component: () => import('../views/Statistics/index.vue'),
        meta: { title: '作业效率统计' },
      },
      {
        path: 'reports',
        name: 'Reports',
        component: () => import('../views/Reports/index.vue'),
        meta: { title: '报表中心' },
      },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
