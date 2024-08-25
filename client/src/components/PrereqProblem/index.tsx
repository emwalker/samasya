import React, { useCallback } from 'react'
import skillService, { PrereqProblemType, RemoveProblemPayload } from '@/services/skills'
import { Box, Card } from '@mantine/core'
import { IconX } from '@tabler/icons-react'
import { notifications } from '@mantine/notifications'
import classes from './index.module.css'

type RemoveButtonProps = {
  payload: RemoveProblemPayload,
  refreshParent: () => void,
}

function RemoveButton({ payload, refreshParent }: RemoveButtonProps) {
  const removeProblem = useCallback(async () => {
    await skillService.removeProblem(payload)
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
  prereqProblem: PrereqProblemType,
  refreshParent: () => void,
}

export default function PrereqProblem({ prereqProblem, refreshParent }: Props) {
  const {
    skillId, prereqProblemId, prereqProblemSummary, prereqApproachName, prereqApproachId,
  } = prereqProblem
  const key = `${prereqProblemId}:${prereqApproachId}`
  const removePayload = { skillId, prereqProblemId, prereqApproachId }

  if (prereqApproachName == null) {
    return (
      <Card key={key} mb={10}>
        <Card.Section className={classes.prereqProblem}>
          <Box className={classes.problemContainer}>
            {prereqProblemSummary}
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
          {prereqProblemSummary}
          <Approach prereqApproachName={prereqApproachName} />
        </Box>
        <RemoveButton payload={removePayload} refreshParent={refreshParent} />
      </Card.Section>
    </Card>
  )
}
