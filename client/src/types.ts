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

export interface ProblemSlice {
  id: string,
  summary: string,
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

export enum AnswerState {
  Correct,
  Incorrect,
  Skipped,
  Started,
  Submitted,
  Unstarted,
}

export type Answer = {
  id: string,
  state: AnswerState,
  summary: string,
}

export type AnswerEdge = {
  node: Answer,
}

export type AnswerConnection = {
  edges: AnswerEdge[],
}

export type QueueStrategy = 'deterministic' | 'spacedRepetitionV1'

export type Queue = {
  id: string,
  summary: string,
  strategy: QueueStrategy,
}

export type WideQueue = Queue & {
  answerConnection: AnswerConnection,
}

export type ApiError = {
  level: 'info' | 'warning' | 'error',
  message: string,
}

export interface ApiResponse<T> {
  data?: T | null,
  errors: ApiError[]
}
