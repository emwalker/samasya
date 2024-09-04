import {
  ApiResponse,
  ApproachType,
  TaskType,
} from '@/types'

type PrereqType = {
  taskId: string,
  taskSummary: string,
  taskAction: string,
  approachId: string
  approachSummary: string,
}

export type FetchData = {
  approach: ApproachType,
  prereqs: PrereqType[],
}

async function fetchApproach(id: string): Promise<ApiResponse<FetchData>> {
  const response = await fetch(
    `http://localhost:8000/api/v1/approaches/${id}`,
    { cache: 'no-store' },
  )
  return response.json()
}

export type AddPayload = {
  summary: string,
  taskId: string,
}

async function add(payload: AddPayload) {
  const response = await fetch(`http://localhost:8000/api/v1/${payload.taskId}/approaches`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
  return response.json()
}

export type UpdatePayload = {
  name: string,
}

async function update(id: string, payload: UpdatePayload) {
  const response = await fetch(`http://localhost:8000/api/v1/approaches/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
  return response.json()
}

export type AvailableData = TaskType[]

async function availablePrereqs(
  approachId: string,
  searchString: string,
): Promise<ApiResponse<AvailableData>> {
  const urlBase = `http://localhost:8000/api/v1/approaches/${approachId}/prereqs/available`
  const url = searchString
    ? `${urlBase}?q=${encodeURIComponent(searchString)}`
    : urlBase
  const response = await fetch(url, {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
  })
  return response.json()
}

export default {
  fetch: fetchApproach, update, add, availablePrereqs,
}
