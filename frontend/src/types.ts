export type Skill = {
  id: string,
  description: string,
}

export type Problem = {
  id: string,
  description: string,
  prerequisiteSkills: Skill[],
  prerequisiteProblems: Problem[],
}
