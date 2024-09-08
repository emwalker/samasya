import {
  ApiError,
  ApiResponse,
  ApproachType,
  Cadence,
  QueueStrategy,
  QueueType,
  TaskType,
} from '@/types'

export type OutcomeRow = {
  addedAt: string,
  approachSummary: string,
  id: string,
  outcome: OutcomeType,
  progress: number,
  taskSummary: string,
  trackName: string,
}

export type QueueOutcomeType = {
  outcome: OutcomeRow,
  taskAvailableAt: string,
}

export type TrackRowType = {
  queueId: string,
  categoryId: string,
  categoryName: string,
  trackId: string,
  trackName: string,
}

export type FetchData = {
  queue: QueueType,
  outcomes: QueueOutcomeType[],
  targetTask: TaskType,
  targetApproach: ApproachType,
  tracks: TrackRowType[],
}

async function fetchQueue(id: string): Promise<ApiResponse<FetchData>> {
  const response = await fetch(
    `http://localhost:8000/api/v1/queues/${id}`,
    { cache: 'no-store' },
  )
  return response.json()
}

export type ListResponse = {
  data: QueueType[]
}

async function list(userId: string): Promise<ListResponse> {
  const res = await fetch(
    `http://localhost:8000/api/v1/users/${userId}/queues`,
    { cache: 'no-store' },
  )

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export type AddPayload = {
  strategy: QueueStrategy,
  summary: string,
  targetApproachId: string,
  cadence: Cadence,
}

async function add(userId: string, payload: AddPayload): Promise<ApiResponse<string>> {
  const response = await fetch(`http://localhost:8000/api/v1/users/${userId}/queues`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
  return response.json()
}

export type UpdatePayload = {
  strategy: QueueStrategy,
  summary: string,
  cadence: Cadence,
}

async function update(queueId: string, payload: UpdatePayload): Promise<ApiResponse<string>> {
  const response = await fetch(`http://localhost:8000/api/v1/queues/${queueId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
  return response.json()
}

type AvailableTrackType = {
  trackId: string,
  trackName: string,
  categoryId: string,
  categoryName: string,
}

type Ready = {
  queue: QueueType,
  task: TaskType,
  taskId: string,
  approach: ApproachType | null,
  approachId: string | null,
  availableAt: Date,
  status: 'ready',
  availableTracks: AvailableTrackType[],
}

type NotReady = {
  queue: QueueType,
  task: null,
  taskId?: undefined,
  approach: null,
  approachId?: undefined,
  availableAt: Date,
  status: 'notReady',
  availableTracks: AvailableTrackType[],
}

type EmptyQueue = {
  queue: QueueType,
  task: null,
  taskId?: undefined,
  approach: null,
  approachId?: undefined,
  availableAt: null,
  status: 'emptyQueue',
  availableTracks: AvailableTrackType[],
}

type NextTaskData = Ready | NotReady | EmptyQueue

export type NextTaskResponse = {
  data: NextTaskData,
  errors: ApiError[],
}

async function nextTask(queueId: string): Promise<NextTaskResponse> {
  const response = await fetch(`http://localhost:8000/api/v1/queues/${queueId}/next-task`, {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
    cache: 'no-store',
  })
  return response.json()
}

export type OutcomeType = 'completed' | 'needsRetry' | 'tooHard'

export type AddOutcomePayload = {
  queueId: string,
  approachId: string,
  repoTrackId: string,
  outcome: OutcomeType,
}

type AddOutcomeData = {
  outcomeId: string,
  message: string,
}

async function addOutcome(payload: AddOutcomePayload): Promise<ApiResponse<AddOutcomeData>> {
  const response = await fetch(
    `http://localhost:8000/api/v1/queues/${payload.queueId}/add-outcome`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    },
  )
  return response.json()
}

export type AvailableTrackData = {
  categoryId: string,
  categoryName: string,
  trackId: string,
  trackName: string,
}

async function availableTracks(
  queueId: string,
  searchString: string,
): Promise<ApiResponse<AvailableTrackData[]>> {
  const encoded = encodeURIComponent(searchString)
  const response = await fetch(
    `http://localhost:8000/api/v1/queues/${queueId}/available-tracks?q=${encoded}`,
    {
      method: 'GET',
    },
  )
  return response.json()
}

export type AddTrackPayload = {
  queueId: string,
  categoryId: string,
  trackId: string,
}

async function addTrack(
  queueId: string,
  payload: AddTrackPayload,
): Promise<ApiResponse<AvailableTrackData[]>> {
  const response = await fetch(
    `http://localhost:8000/api/v1/queues/${queueId}/add-track`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    },
  )
  return response.json()
}

export type RemoveTrackPayload = {
  queueId: string,
  trackId: string,
}

async function removeTrack(
  queueId: string,
  payload: RemoveTrackPayload,
): Promise<ApiResponse<string>> {
  const response = await fetch(
    `http://localhost:8000/api/v1/queues/${queueId}/remove-track`,
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
  addOutcome,
  addTrack,
  availableTracks,
  fetch: fetchQueue,
  list,
  nextTask,
  removeTrack,
  update,
}
