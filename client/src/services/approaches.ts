import { ApproachType, WideApproach } from '@/types'

export type GetResponse = {
  data: WideApproach | null
}

async function get(id: string): Promise<GetResponse> {
  const res = await fetch(`http://localhost:8000/api/v1/approaches/${id}`, { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: null })
  }

  return res.json()
}

export type GetListResponse = {
  data: ApproachType[]
}

async function getList(problemId: string): Promise<GetListResponse> {
  const res = await fetch(
    `http://localhost:8000/api/v1/problems/${problemId}/approaches`,
    { cache: 'no-store' },
  )

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export type Update = {
  name: string,
  prereqApproachIds: string[],
  prereqSkillIds: string[],
  problemId: string,
}

async function put(id: string, update: Update) {
  return fetch(`http://localhost:8000/api/v1/approaches/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(update),
  })
}

async function post(update: Update) {
  return fetch('http://localhost:8000/api/v1/approaches', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(update),
  })
}

export default {
  get, getList, put, post,
}
