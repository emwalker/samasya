import {
  QueueStrategy, QueueType, ApiError,
  AnswerConnection,
  ProblemType,
  ApproachType,
} from '@/types'

export type FetchResponse = {
  data: {
    queue: QueueType,
    answers: AnswerConnection,
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

export type UpdateResponse = {
  data: any,
  errors: ApiError[],
};

async function add(userId: string, update: UpdatePayload): Promise<UpdateResponse> {
  const res = await fetch(`http://localhost:8000/api/v1/users/${userId}/queues`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(update),
  })
  return res.json()
}

type Ready = {
  problem: ProblemType,
  approach: ApproachType | null,
  availableAt: Date,
  status: 'ready',
}

type NotReady = {
  problem: null,
  approach: null,
  availableAt: Date,
  status: 'notReady',
}

type EmptyQueue = {
  problem: null,
  approach: null,
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

export default {
  fetch: fetchQueue, list, add, nextProblem,
}
