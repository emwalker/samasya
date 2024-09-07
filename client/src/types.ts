export type SkillType = {
  id: string,
  summary: string,
  description: string | null,
}

export type TaskAction = 'acquireSkill' | 'completeProblem'

export interface TaskType {
  id: string,
  summary: string,
  action: TaskAction,
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
  summary: string,
  taskId: string,
}

export type WideApproach = ApproachType & {
  prereqApproaches: ApproachType[],
  prereqTasks: SkillType[],
  problem: TaskType,
}

export type OutcomeType = 'completed' | 'needsRetry' | 'tooHard'

export type Cadence = 'minutes' | 'hours' | 'days'

export type Outcome = {
  id: string,
  outcome: OutcomeType,
  summary: string,
}

export type QueueStrategy = 'deterministic' | 'spacedRepetitionV1'

export type QueueType = {
  id: string,
  summary: string,
  strategy: QueueStrategy,
  cadence: Cadence,
}

export type ApiError = {
  level: 'info' | 'warning' | 'error',
  message: string,
}

export interface ApiResponse<T> {
  data?: T | null,
  errors: ApiError[]
}
