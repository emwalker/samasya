import {
  ApiResponse,
  ApproachType,
  TaskAction,
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
  questionPrompt: string | null,
  questionUrl: string | null,
  summary: string,
  taskId: string,
}

async function update(taskId: string, payload: UpdatePayload): Promise<ApiResponse<string>> {
  const response = await fetch(`http://localhost:8000/api/v1/tasks/${taskId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
  return response.json()
}

export type AddPayload = {
  action: TaskAction,
  questionPrompt: string | null,
  questionUrl: string | null,
  repoId: string,
  summary: string,
}

type AddData = {
  addedTaskId: string,
}

async function add(repoId: string, payload: AddPayload): Promise<ApiResponse<AddData>> {
  const response = await fetch(`http://localhost:8000/api/v1/repos/${repoId}/tasks`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
  return response.json()
}

async function remove(taskId: string): Promise<ApiResponse<string>> {
  const response = await fetch(`http://localhost:8000/api/v1/tasks/${taskId}`, {
    method: 'DELETE',
  })
  return response.json()
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
  add,
  addPrereq,
  fetch: fetchTask,
  list,
  remove,
  removePrereq,
  update,
}
