import {
  Cadence,
  OutcomeType,
  QueueStrategy,
  TaskAction,
} from './types'

export function actionText(action: TaskAction) {
  if (action === 'acquireAbility') return 'Ability'
  if (action === 'acquireSkill') return 'Skill'
  if (action === 'answerQuestion') return 'Question'
  if (action === 'completeProblem') return 'Problem'
  if (action === 'completeSet') return 'Question set'
  return action
}

export function actionColor(action: string) {
  if (action === 'completeProblem') return 'green.4'
  if (action === 'acquireSkill') return 'cyan.3'
  return 'yellow'
}

export function outcomeText(outcome: OutcomeType) {
  if (outcome === 'completed') return 'Correct'
  if (outcome === 'needsRetry') return 'Incorrect'
  if (outcome === 'tooHard') return 'Unsure'
  return outcome
}

export function cadenceText(cadence: Cadence) {
  if (cadence === 'minutes') return 'Progresses minute by minute'
  if (cadence === 'hours') return 'Progresses hourly'
  if (cadence === 'days') return 'Progresses daily'
  return cadence
}

export function queueStrategyText(strategy: QueueStrategy) {
  if (strategy === 'spacedRepetitionV1') return 'Spaced repetition'
  if (strategy === 'deterministic') return 'Deterministic task selection'
  return strategy
}
