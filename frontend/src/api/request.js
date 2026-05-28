import axios from 'axios'

const api = axios.create({
  baseURL: '/api/v1',
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' },
})

// 响应拦截器：统一处理 FastAPI 错误
api.interceptors.response.use(
  (res) => res,
  (error) => {
    const detail = error.response?.data?.detail
    const msg = detail
      ? (typeof detail === 'string' ? detail : JSON.stringify(detail))
      : (error.message || '网络请求失败')
    alert('请求错误: ' + msg)
    return Promise.reject(error)
  }
)

export default api
