import { ApiError, Skill } from '@/types'

export type GetListResponse = {
  data: Skill[]
}

async function getList(
  args?: { searchString: string | null } | undefined,
): Promise<GetListResponse> {
  const url = args?.searchString
    ? `http://localhost:8000/api/v1/skills?q=${args.searchString}`
    : 'http://localhost:8000/api/v1/skills'
  const res = await fetch(url, { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export type PrereqProblemType = {
  prereqApproachId: string | null,
  prereqApproachName: string | null,
  prereqProblemId: string,
  prereqProblemSummary: string,
  skillId: string,
}

type WideSkill = {
  skill: Skill,
  prereqProblems: PrereqProblemType[],
}

export type GetResponse = {
  data: WideSkill | null,
  errors: ApiError[]
}

async function get(id: string): Promise<GetResponse> {
  const url = `http://localhost:8000/api/v1/skills/${id}`
  const res = await fetch(url, { cache: 'no-store' })
  return res.json()
}

export type UpdatePayload = {
  summary: string,
  description: string | null,
}

async function add(updatePayload: UpdatePayload) {
  return fetch('http://localhost:8000/api/v1/skills', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(updatePayload),
  })
}

async function update(skillId: string, updatePayload: UpdatePayload) {
  return fetch(`http://localhost:8000/api/v1/skills/${skillId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(updatePayload),
  })
}

type AddProblemPayload = {
  skillId: string,
  prereqProblemId: string,
  prereqApproachId: string | null
}

async function addProblem(payload: AddProblemPayload) {
  return fetch(`http://localhost:8000/api/v1/skills/${payload.skillId}/prereqs/add-problem`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
}

export type RemoveProblemPayload = {
  skillId: string,
  prereqProblemId: string,
  prereqApproachId: string | null
}

async function removeProblem(payload: RemoveProblemPayload) {
  return fetch(`http://localhost:8000/api/v1/skills/${payload.skillId}/prereqs/remove-problem`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
}

export default {
  get, getList, add, addProblem, removeProblem, update,
}
