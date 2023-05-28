import { Skill } from '@/types'

export type GetSkillsResponse = {
  data: Skill[]
}

async function getSkills(): Promise<GetSkillsResponse> {
  const res = await fetch('http://localhost:8000/api/v1/skills', { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export type SkillUpdate = {
  description: string,
}

async function postSkill({ update }: { update: SkillUpdate }) {
  return fetch('http://localhost:8000/api/v1/skills', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(update),
  })
}

export { getSkills, postSkill }
