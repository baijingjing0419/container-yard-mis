import api from './request'
export const getSeaPlanList = (p) => api.get('/sea-plans', { params: p }).then(r => r.data)
export const createSeaPlan = (d) => api.post('/sea-plans', d).then(r => r.data)
