import {
  QueueStrategy, QueueType, ApiError,
  AnswerConnection,
  ProblemType,
} from '@/types'

export type GetResponse = {
  data: {
    queue: QueueType,
    answers: AnswerConnection,
    targetProblem: ProblemType,
  } | null
}

async function get(id: string): Promise<GetResponse> {
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

async function getList(userId: string): Promise<ListResponse> {
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

export default { get, getList, add }
