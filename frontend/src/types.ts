export type Skill = {
  id: string,
  description: string,
}

export type Problem = {
  id: string,
  description: string,
  prerequisiteSkills: Skill[]
}

export type GetProblemResponse = {
  data: Problem | null
}

export type GetProblemsResponse = {
  data: Problem[] | null
}

export type GetSkillsResponse = {
  data: Skill[] | null
}
