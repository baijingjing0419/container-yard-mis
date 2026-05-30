import api from './request'
export const getLandPlanList = (p) => api.get('/land-plans', { params: p }).then(r => r.data)
export const createLandPlan = (d) => api.post('/land-plans', d).then(r => r.data)
