import axios, { type AxiosInstance, type AxiosResponse } from 'axios'

const api: AxiosInstance = axios.create({
  baseURL: '/api/v1',
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' },
})

api.interceptors.response.use(
  (res: AxiosResponse) => res,
  (error) => {
    const status = error.response?.status
    const detail = error.response?.data?.detail
    const msg = detail
      ? (typeof detail === 'string' ? detail : JSON.stringify(detail))
      : (error.message || '网络请求失败')

    if (status === 409) {
      // 乐观锁冲突：使用 Pinia toast 通知（通过 window 上挂载的 store）
      const appStore = (window as any).__appStore
      if (appStore) {
        appStore.showToast(msg || '当前箱位已被其他指令抢占，请刷新后重试', 'error')
      } else {
        alert(msg || '当前箱位已被其他指令抢占，请刷新后重试')
      }
    } else {
      alert('请求错误: ' + msg)
    }
    return Promise.reject(error)
  },
)

export default api
