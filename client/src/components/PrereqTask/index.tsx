import React, { useCallback } from 'react'
import taskService, { PrereqTaskType, RemoveTaskPayload } from '@/services/tasks'
import { Box, Card } from '@mantine/core'
import { IconX } from '@tabler/icons-react'
import { notifications } from '@mantine/notifications'
import classes from './index.module.css'

type RemoveButtonProps = {
  payload: RemoveTaskPayload,
  refreshParent: () => void,
}

function RemoveButton({ payload, refreshParent }: RemoveButtonProps) {
  const removeProblem = useCallback(async () => {
    await taskService.removePrereqTask(payload)
    notifications.show({
      title: 'Problem removed',
      color: 'blue',
      position: 'top-center',
      message: 'A problem/approach has been removed from this skill',
    })
    refreshParent()
  }, [payload, refreshParent])

  return (
    <Box onClick={removeProblem} className={classes.removeButton}>
      <IconX color="var(--mantine-color-dark-1)" />
    </Box>
  )
}

type ApproachProps = {
  prereqApproachName: string,
}

function Approach({ prereqApproachName }: ApproachProps) {
  return (
    <div>
      <span className={classes.approach}>Approach: {prereqApproachName}</span>
    </div>
  )
}

type Props = {
  prereqTask: PrereqTaskType,
  refreshParent: () => void,
}

export default function PrereqTask({ prereqTask, refreshParent }: Props) {
  const {
    taskId, prereqTaskId, prereqTaskSummary, prereqApproachName, prereqApproachId,
  } = prereqTask
  const key = `${prereqTaskId}:${prereqApproachId}`
  const removePayload = { taskId, prereqTaskId, prereqApproachId }

  if (prereqApproachName == null) {
    return (
      <Card key={key} mb={10}>
        <Card.Section className={classes.prereqProblem}>
          <Box className={classes.problemContainer}>
            {prereqTaskSummary}
            <Approach prereqApproachName="any" />
          </Box>
          <RemoveButton payload={removePayload} refreshParent={refreshParent} />
        </Card.Section>
      </Card>
    )
  }

  return (
    <Card key={key} mb={10}>
      <Card.Section className={classes.prereqProblem}>
        <Box className={classes.problemContainer}>
          {prereqTaskSummary}
          <Approach prereqApproachName={prereqApproachName} />
        </Box>
        <RemoveButton payload={removePayload} refreshParent={refreshParent} />
      </Card.Section>
    </Card>
  )
}
