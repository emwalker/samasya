export type Skill = {
  id: string,
  summary: string,
}

export interface Problem {
  id: string,
  summary: string,
  questionText: string | null,
  questionUrl: string | null,
}

export type WideProblem = Problem & {
  // eslint-disable-next-line no-use-before-define
  approaches: WideApproach[],
}

export interface Approach {
  default: boolean,
  id: string,
  name: string,
  summary: string,
}

export type WideApproach = Approach & {
  prereqApproaches: Approach[],
  prereqSkills: Skill[],
  problem: Problem,
}
