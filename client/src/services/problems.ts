import {
  ProblemType, ApiError, SkillType, ApproachType,
} from '@/types'

export type FetchResponse = {
  data: {
    problem: ProblemType,
    approaches: ApproachType[],
    prereqSkills: SkillType[],
  } | null,
  errors: ApiError[]
}

async function fetchProblem(id: string): Promise<FetchResponse> {
  const response = await fetch(
    `http://localhost:8000/api/v1/problems/${id}`,
    { cache: 'no-store' },
  )
  return response.json()
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

async function update(id: string, payload: UpdatePayload) {
  return fetch(`http://localhost:8000/api/v1/problems/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
}

async function add(payload: UpdatePayload) {
  return fetch('http://localhost:8000/api/v1/problems', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
}

export default {
  fetch: fetchProblem, list, update, add,
}
