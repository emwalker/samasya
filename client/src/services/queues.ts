import { QueueStrategy, Queue, WideQueue } from '@/types'

export type GetResponse = {
  data: WideQueue | null
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

export type GetListResponse = {
  data: Queue[]
}

async function getList(userId: string): Promise<GetListResponse> {
  const res = await fetch(
    `http://localhost:8000/api/v1/users/${userId}/queues`,
    { cache: 'no-store' },
  )

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export type Update = {
  strategy: QueueStrategy,
  summary: string,
  targetProblemId: string,
}

async function post(userId: string, update: Update) {
  return fetch(`http://localhost:8000/api/v1/users/${userId}/queues`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(update),
  })
}

export default { get, getList, post }
