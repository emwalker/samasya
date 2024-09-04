import {
  TaskType, ApiError, ApproachType,
} from '@/types'

export type PrereqTaskType = {
  taskId: string,
  prereqApproachId: string,
  prereqApproachName: string,
  prereqTaskId: string,
  prereqTaskSummary: string,
}

export type FetchResponse = {
  data: {
    task: TaskType,
    approaches: ApproachType[],
    prereqTasks: PrereqTaskType[],
  } | null,
  errors: ApiError[]
}

async function fetchTask(id: string): Promise<FetchResponse> {
  const response = await fetch(
    `http://localhost:8000/api/v1/tasks/${id}`,
    { cache: 'no-store' },
  )
  return response.json()
}

export type ListResponse = {
  data: TaskType[]
}

async function list(
  searchString?: string | null,
): Promise<ListResponse> {
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

type PrereqResponse = {
  data: string | null,
  errors: ApiError[],
}

type AddPrereqTaskPayload = {
  taskId: string,
  prereqTaskId: string,
  prereqApproachId: string,
}

async function addPrereqTask(payload: AddPrereqTaskPayload): Promise<PrereqResponse> {
  const response = await fetch(
    `http://localhost:8000/api/v1/tasks/${payload.taskId}/prereqs/add-task`,
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

async function removePrereqTask(payload: RemoveTaskPayload): Promise<PrereqResponse> {
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

type AvailablePrereqTasksResponse = {
  data: TaskType[] | null,
  errors: ApiError[],
}

async function availablePrereqTasks(
  taskId: string,
  searchString: string,
): Promise<AvailablePrereqTasksResponse> {
  const urlBase = `http://localhost:8000/api/v1/tasks/${taskId}/prereqs/available-tasks`
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
  fetch: fetchTask, list, update, add, addPrereqTask, removePrereqTask, availablePrereqTasks,
}
