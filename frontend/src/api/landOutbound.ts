import api from './request'
export const getLandOutboundList = (p) => api.get('/land-outbounds', { params: p }).then(r => r.data)
export const createLandOutbound = (d) => api.post('/land-outbounds', d).then(r => r.data)
