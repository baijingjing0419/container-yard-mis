import api from './request'
export const getSeaOutboundList = (p) => api.get('/sea-outbounds', { params: p }).then(r => r.data)
export const createSeaOutbound = (d) => api.post('/sea-outbounds', d).then(r => r.data)
