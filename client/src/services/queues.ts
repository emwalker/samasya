import {
  QueueStrategy, QueueType, ApiError,
  ProblemType,
  ApproachType,
  ApiResponse,
} from '@/types'

export type QueueAnswerType = {
  problemSummary: string,
  answerId: string,
  answerAnsweredAt: string,
  answerAvailableAt: string,
  answerState: AnswerState,
  answerConsecutiveCorrect: number,
}

export type FetchResponse = {
  data: {
    queue: QueueType,
    answers: QueueAnswerType[],
    targetProblem: ProblemType,
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
  targetProblemId: string,
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
  problem: ProblemType,
  problemId: string,
  approach: ApproachType | null,
  approachId: string | null,
  availableAt: Date,
  status: 'ready',
}

type NotReady = {
  queue: QueueType,
  problem: null,
  problemId?: undefined,
  approach: null,
  approachId?: undefined,
  availableAt: Date,
  status: 'notReady',
}

type EmptyQueue = {
  queue: QueueType,
  problem: null,
  problemId?: undefined,
  approach: null,
  approachId?: undefined,
  availableAt: null,
  status: 'emptyQueue',
}

type NextProblemData = Ready | NotReady | EmptyQueue

export type NextProblemResponse = {
  data: NextProblemData,
  errors: ApiError[],
}

async function nextProblem(queueId: string): Promise<NextProblemResponse> {
  const response = await fetch(`http://localhost:8000/api/v1/queues/${queueId}/next-problem`, {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
    cache: 'no-store',
  })
  return response.json()
}

export type AnswerState = 'correct' | 'incorrect' | 'unsure'

export type AnswerProblemPayload = {
  queueId: string,
  problemId: string,
  approachId: string | null,
  answerState: AnswerState,
}

type AnswerProblemResponse = {
  data: {
    answerId: string,
    message: string,
  } | null,
  errors: ApiError[],
}

async function addAnswer(payload: AnswerProblemPayload): Promise<AnswerProblemResponse> {
  const response = await fetch(
    `http://localhost:8000/api/v1/queues/${payload.queueId}/add-answer`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    },
  )
  return response.json()
}

export default {
  fetch: fetchQueue, list, add, nextProblem, addAnswer,
}
