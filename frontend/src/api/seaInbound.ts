import api from './request'

export function getSeaInboundList(params = {}) {
  return api.get('/sea-inbounds', { params }).then(r => r.data)
}

export function createSeaInbound(data) {
  return api.post('/sea-inbounds', data).then(r => r.data)
}
