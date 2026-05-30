import api from './request'
export const getLandInboundList = (p) => api.get('/land-inbounds', { params: p }).then(r => r.data)
export const createLandInbound = (d) => api.post('/land-inbounds', d).then(r => r.data)
