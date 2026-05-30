import axios, { type AxiosInstance, type AxiosResponse } from 'axios'

const api: AxiosInstance = axios.create({
  baseURL: '/api/v1',
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' },
})

api.interceptors.response.use(
  (res: AxiosResponse) => res,
  (error) => {
    const detail = error.response?.data?.detail
    const msg = detail
      ? (typeof detail === 'string' ? detail : JSON.stringify(detail))
      : (error.message || '网络请求失败')
    alert('请求错误: ' + msg)
    return Promise.reject(error)
  },
)

export default api
