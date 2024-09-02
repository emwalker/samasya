import React from 'react'
import { Anchor, Box } from '@mantine/core'

type Props = {
  questionUrl: string,
}

export default function QuestionUrlPrompt({ questionUrl }: Props) {
  return (
    <Box>
      Visit <Anchor target="_blank" href={questionUrl}>this link</Anchor> and
      complete the problem.  Click on the button below that corresponds to the result of
      your first attempt this round.
    </Box>
  )
}
