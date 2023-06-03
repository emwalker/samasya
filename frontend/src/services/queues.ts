import { Skill } from '@/types'

export type GetListResponse = {
  data: Skill[]
}

async function getList(userId: string): Promise<GetListResponse> {
  const res = await fetch(`http://localhost:8000/api/v1/users/${userId}/queues`,
    { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export type Update = {
  strategy: number,
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

export default { getList, post }
