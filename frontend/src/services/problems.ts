import { Problem } from '@/types'

export type GetProblemResponse = {
  data: Problem | null
}

async function getProblem({ id }: { id: string }): Promise<GetProblemResponse> {
  const res = await fetch(`http://localhost:8000/api/v1/problems/${id}`, { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: null })
  }

  return res.json()
}

export type GetProblemsResponse = {
  data: Problem[]
}

async function getProblems(): Promise<GetProblemsResponse> {
  const res = await fetch('http://localhost:8000/api/v1/problems', { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export type ProblemUpdate = {
  description: string,
  prerequisiteSkillIds: string[],
  prerequisiteProblemIds: string[],
}

type PutProblemProps = {
  id: string,
  update: ProblemUpdate,
}

async function putProblem({ id, update }: PutProblemProps) {
  return fetch(`http://localhost:8000/api/v1/problems/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(update),
  })
}

export { getProblem, getProblems, putProblem }
