import { Skill } from '@/types'

export type GetListResponse = {
  data: Skill[]
}

async function getList(): Promise<GetListResponse> {
  const res = await fetch('http://localhost:8000/api/v1/skills', { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export type Update = {
  description: string,
}

async function post(update: Update) {
  return fetch('http://localhost:8000/api/v1/skills', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(update),
  })
}

export default { getList, post }
