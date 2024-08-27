import { ProblemType, WideProblem, ApiError } from '@/types'

export type GetResponse = {
  data: WideProblem | null,
  errors: ApiError[]
}

async function get(id: string): Promise<GetResponse> {
  const res = await fetch(`http://localhost:8000/api/v1/problems/${id}`, { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({
      data: null,
      errors: [{ level: 'error', message: 'Something happened' }],
    })
  }

  return res.json()
}

export type ListResponse = {
  data: ProblemType[]
}

async function list(
  args?: { searchString: string | null } | undefined,
): Promise<ListResponse> {
  const url = args?.searchString
    ? `http://localhost:8000/api/v1/problems?q=${encodeURIComponent(args?.searchString)}`
    : 'http://localhost:8000/api/v1/problems'
  const res = await fetch(url, { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export type UpdatePayload = {
  questionText: string | null,
  questionUrl: string | null,
  summary: string,
}

async function update(id: string, updatePayload: UpdatePayload) {
  return fetch(`http://localhost:8000/api/v1/problems/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(updatePayload),
  })
}

async function add(updatePayload: UpdatePayload) {
  return fetch('http://localhost:8000/api/v1/problems', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(updatePayload),
  })
}

export default {
  get, list, update, add,
}
