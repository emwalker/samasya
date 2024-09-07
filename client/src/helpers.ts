import { OutcomeType, TaskAction } from './types'

export function actionText(action: TaskAction) {
  if (action === 'completeProblem') return 'Complete problem'
  if (action === 'acquireSkill') return 'Acquire skill'
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
