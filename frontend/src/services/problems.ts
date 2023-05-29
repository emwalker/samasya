import { Problem, WideProblem } from '@/types'

export type GetResponse = {
  data: WideProblem | null
}

async function get(id: string): Promise<GetResponse> {
  const res = await fetch(`http://localhost:8000/api/v1/problems/${id}`, { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: null })
  }

  return res.json()
}

export type GetListResponse = {
  data: Problem[]
}

async function getList(): Promise<GetListResponse> {
  const res = await fetch('http://localhost:8000/api/v1/problems', { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export type Update = {
  questionText: string | null,
  questionUrl: string | null,
  summary: string,
}

async function put(id: string, update: Update) {
  return fetch(`http://localhost:8000/api/v1/problems/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(update),
  })
}

async function post(update: Update) {
  return fetch('http://localhost:8000/api/v1/problems', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(update),
  })
}

export default {
  get, getList, put, post,
}
