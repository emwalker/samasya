import React, { useCallback } from 'react'
import { PrereqProblemType } from '@/services/skills'
import { Box, Card } from '@mantine/core'
import { IconX } from '@tabler/icons-react'
import classes from './index.module.css'

type RemoveButtonProps = {
  skillId: string,
  prereqProblemId: string,
  prereqApproachId: string | null,
}

function RemoveButton({ skillId, prereqProblemId, prereqApproachId }: RemoveButtonProps) {
  const removeProblem = useCallback(() => {
    // eslint-disable-next-line no-console
    console.log('removing problem', prereqProblemId, 'for skill', skillId, 'and approach', prereqApproachId)
  }, [skillId, prereqProblemId, prereqApproachId])

  return (
    <Box onClick={removeProblem} className={classes.removeButton}>
      <IconX
        color="var(--mantine-color-dark-1)"
      />
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

export default function PrereqProblem(
  {
    skillId, prereqProblemId, prereqProblemSummary, prereqApproachName, prereqApproachId,
  }: PrereqProblemType,
) {
  const key = `${prereqProblemId}:${prereqApproachId}`

  if (prereqApproachName == null) {
    return (
      <Card key={key} mb={10}>
        <Card.Section className={classes.prereqProblem}>
          <Box className={classes.problemContainer}>
            {prereqProblemSummary}
            <Approach prereqApproachName="any" />
          </Box>
          <RemoveButton
            skillId={skillId}
            prereqProblemId={prereqProblemId}
            prereqApproachId={prereqApproachId}
          />
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
        <RemoveButton
          skillId={skillId}
          prereqProblemId={prereqProblemSummary}
          prereqApproachId={prereqApproachId}
        />
      </Card.Section>
    </Card>
  )
}
