'use client'

import React, {
  useState, useCallback, ChangeEvent,
} from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import queueService from '@/services/queues'
import contants from '@/constants'
import TaskApproachSelect from '@/components/TaskApproachSelect'
import { Box, Button, TextInput } from '@mantine/core'
import handleResponse from '@/app/handleResponse'
import TitleAndButton from '@/components/TitleAndButton'

type AddButtonProps = {
  disabled: boolean,
  summary: string,
  targetProblemId: string,
}

function AddButton({ disabled, summary, targetProblemId: targetTaskId }: AddButtonProps) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    const response = await queueService.add(
      contants.placeholderUserId,
      {
        summary, targetTaskId, strategy: 'spacedRepetitionV1', cadence: 'hours',
      },
    )

    handleResponse(router, response, '/learning/queues', 'Unable to add queue')
  }, [summary, targetTaskId, router])

  return (
    <Button disabled={disabled} onClick={onClick} type="submit">Start</Button>
  )
}

export default function Page() {
  const [summary, setSummary] = useState('')
  const [targetTaskId, setTargetApproachId] = useState('')

  const summaryOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  const taskOnChange = useCallback(
    (problemId: string | null) => {
      if (problemId == null) {
        setTargetApproachId('')
      } else {
        setTargetApproachId(problemId)
      }
    },
    [setTargetApproachId],
  )

  const disabled = summary.length === 0 || targetTaskId.length === 0

  return (
    <Box>
      <TitleAndButton title="Start a queue">
        <AddButton
          disabled={disabled}
          summary={summary}
          targetProblemId={targetTaskId}
        />
        {' or '}
        <Link href="/learning/queues">cancel</Link>
      </TitleAndButton>

      <TextInput
        onChange={summaryOnChange}
        placeholder="Name of queue"
        label="Name"
        type="text"
        value={summary}
      />

      <TaskApproachSelect
        label="Challenge to work towards"
        setApproachId={taskOnChange}
      />
    </Box>
  )
}
