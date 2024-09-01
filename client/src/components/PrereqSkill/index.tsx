import React, { useCallback } from 'react'
import problemService, { PrereqSkillType, RemoveSkillPayload } from '@/services/problems'
import { Box, Card } from '@mantine/core'
import { IconX } from '@tabler/icons-react'
import { notifications } from '@mantine/notifications'
import classes from './index.module.css'

type RemoveButtonProps = {
  payload: RemoveSkillPayload,
  refreshParent: () => void,
}

function RemoveButton({ payload, refreshParent }: RemoveButtonProps) {
  const removeProblem = useCallback(async () => {
    await problemService.removeSkill(payload)
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

type Props = {
  prereqSkill: PrereqSkillType,
  refreshParent: () => void,
}

export default function PrereqSkill({ prereqSkill, refreshParent }: Props) {
  const {
    prereqSkillId, prereqSkillSummary, problemId, approachId,
  } = prereqSkill
  const key = `${problemId}:${approachId}:${prereqSkillId}`
  const removePayload = { problemId, approachId, prereqSkillId }

  return (
    <Card key={key} mb={10}>
      <Card.Section className={classes.prereqSkill}>
        <Box className={classes.skillContainer}>
          {prereqSkillSummary}
        </Box>
        <RemoveButton payload={removePayload} refreshParent={refreshParent} />
      </Card.Section>
    </Card>
  )
}
