import {
  ApiError,
  ApiResponse,
  ApproachType,
  Cadence,
  QueueStrategy,
  QueueType,
  TaskType,
} from '@/types'

export type QueueAnswerType = {
  problemSummary: string,
  answerId: string,
  answerAnsweredAt: string,
  answerAvailableAt: string,
  answerState: OutcomeType,
  answerConsecutiveCorrect: number,
}

export type FetchResponse = {
  data: {
    queue: QueueType,
    answers: QueueAnswerType[],
    targetTask: TaskType,
  } | null
}

async function fetchQueue(id: string): Promise<FetchResponse> {
  const res = await fetch(
    `http://localhost:8000/api/v1/queues/${id}`,
    { cache: 'no-store' },
  )

  if (!res.ok) {
    return Promise.resolve({ data: null })
  }

  return res.json()
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

export type UpdatePayload = {
  strategy: QueueStrategy,
  summary: string,
  targetTaskId: string,
  cadence: Cadence,
}

async function add(userId: string, update: UpdatePayload): Promise<ApiResponse<any>> {
  const res = await fetch(`http://localhost:8000/api/v1/users/${userId}/queues`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(update),
  })
  return res.json()
}

type Ready = {
  queue: QueueType,
  task: TaskType,
  taskId: string,
  approach: ApproachType | null,
  approachId: string | null,
  availableAt: Date,
  status: 'ready',
}

type NotReady = {
  queue: QueueType,
  task: null,
  taskId?: undefined,
  approach: null,
  approachId?: undefined,
  availableAt: Date,
  status: 'notReady',
}

type EmptyQueue = {
  queue: QueueType,
  task: null,
  taskId?: undefined,
  approach: null,
  approachId?: undefined,
  availableAt: null,
  status: 'emptyQueue',
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

export type AnswerProblemPayload = {
  queueId: string,
  taskId: string,
  approachId: string | null,
  outcome: OutcomeType,
}

type OutcomeResponse = {
  data: {
    outcomeId: string,
    message: string,
  } | null,
  errors: ApiError[],
}

async function addOutcome(payload: AnswerProblemPayload): Promise<OutcomeResponse> {
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

export default {
  fetch: fetchQueue, list, add, nextTask, addOutcome,
}
