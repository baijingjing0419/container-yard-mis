import api from './request'
import type { ContainerMaster, ContainerMoveLog, PaginatedItems } from '../types'

export function getContainers(params: Record<string, unknown> = {}) {
  return api.get<PaginatedItems<ContainerMaster>>('/containers', { params }).then(r => r.data)
}

export function getContainer(containerId: string) {
  return api.get<ContainerMaster>(`/containers/${containerId}`).then(r => r.data)
}

export function getContainerMoveLogs(containerId: string, params: Record<string, unknown> = {}) {
  return api.get<PaginatedItems<ContainerMoveLog>>(`/containers/${containerId}/move-logs`, { params }).then(r => r.data)
}
