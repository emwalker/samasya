export type SkillType = {
  id: string,
  summary: string,
  description: string | null,
}

export interface TaskType {
  id: string,
  summary: string,
  questionText: string | null,
  questionUrl: string | null,
}

export type WideProblem = TaskType & {
  // eslint-disable-next-line no-use-before-define
  approaches: WideApproach[],
}

export interface ProblemSlice {
  id: string,
  summary: string,
}

export interface ApproachType {
  unspecified: boolean,
  id: string,
  name: string,
  summary: string,
}

export type WideApproach = ApproachType & {
  prereqApproaches: ApproachType[],
  prereqSkills: SkillType[],
  problem: TaskType,
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

export type QueueType = {
  id: string,
  summary: string,
  strategy: QueueStrategy,
}

export type ApiError = {
  level: 'info' | 'warning' | 'error',
  message: string,
}

export interface ApiResponse<T> {
  data?: T | null,
  errors: ApiError[]
}
