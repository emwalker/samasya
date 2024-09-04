import {
  ApiResponse,
  ApproachType,
  TaskType,
} from '@/types'

export type FetchData = {
  task: TaskType,
  approaches: ApproachType[],
}

async function fetchTask(id: string): Promise<ApiResponse<FetchData>> {
  const response = await fetch(
    `http://localhost:8000/api/v1/tasks/${id}`,
    { cache: 'no-store' },
  )
  return response.json()
}

export type ListData = TaskType[]

async function list(
  searchString?: string | null,
): Promise<ApiResponse<ListData>> {
  const url = searchString
    ? `http://localhost:8000/api/v1/tasks?q=${encodeURIComponent(searchString)}`
    : 'http://localhost:8000/api/v1/tasks'
  const response = await fetch(url, { cache: 'no-store' })
  return response.json()
}

export type UpdatePayload = {
  questionText: string | null,
  questionUrl: string | null,
  summary: string,
}

async function update(id: string, payload: UpdatePayload) {
  return fetch(`http://localhost:8000/api/v1/tasks/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
}

async function add(payload: UpdatePayload) {
  return fetch('http://localhost:8000/api/v1/tasks', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
}

export type AddPrereqPayload = {
  taskId: string,
  approachId: string,
  prereqTaskId: string,
  prereqApproachId: string,
}

async function addPrereq(payload: AddPrereqPayload): Promise<ApiResponse<string>> {
  const response = await fetch(
    `http://localhost:8000/api/v1/tasks/${payload.taskId}/prereqs/add`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    },
  )
  return response.json()
}

export type RemoveTaskPayload = {
  taskId: string,
  prereqTaskId: string,
  prereqApproachId: string,
}

async function removePrereq(payload: RemoveTaskPayload): Promise<ApiResponse<string>> {
  const response = await fetch(
    `http://localhost:8000/api/v1/tasks/${payload.taskId}/prereqs/remove-task`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    },
  )
  return response.json()
}

export default {
  fetch: fetchTask, list, update, add, addPrereq, removePrereq,
}
