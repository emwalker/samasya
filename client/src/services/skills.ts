import { ApiError, ProblemType, SkillType } from '@/types'

export type ListResponse = {
  data: SkillType[]
}

async function list(
  args?: { searchString: string | null } | undefined,
): Promise<ListResponse> {
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
  skill: SkillType,
  prereqProblems: PrereqProblemType[],
}

export type FetchResponse = {
  data: WideSkill | null,
  errors: ApiError[]
}

async function fetchSkill(id: string): Promise<FetchResponse> {
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

export type AvailablePrereqProblems = {
  data: ProblemType[],
  errors: ApiError[],
}

async function availablePrereqProblems(
  skillId: string,
  searchString: string,
): Promise<AvailablePrereqProblems> {
  const q = encodeURIComponent(searchString)
  const url = `http://localhost:8000/api/v1/skills/${skillId}/prereqs/available-problems?q=${q}`
  const response = await fetch(url, {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
  })
  return response.json()
}

export default {
  fetch: fetchSkill, list, add, addProblem, removeProblem, update, availablePrereqProblems,
}
