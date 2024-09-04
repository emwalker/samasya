'use client'

import React, {
  useState, useCallback, ChangeEvent,
} from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import queueService, { UpdatePayload } from '@/services/queues'
import contants from '@/constants'
import TaskApproachSelect from '@/components/TaskApproachSelect'
import { Box, Button, TextInput } from '@mantine/core'
import handleResponse from '@/app/handleResponse'
import TitleAndButton from '@/components/TitleAndButton'
import taskService from '@/services/tasks'

type AddButtonProps = {
  disabled: boolean,
  summary: string,
  targetApproachId: string | null,
}

function AddButton({ disabled, summary, targetApproachId }: AddButtonProps) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    if (targetApproachId == null) return
    const payload: UpdatePayload = {
      summary, targetApproachId, strategy: 'spacedRepetitionV1', cadence: 'hours',
    }
    const response = await queueService.add(contants.placeholderUserId, payload)
    handleResponse(router, response, '/learning/queues', 'Unable to add queue')
  }, [summary, targetApproachId, router])

  return (
    <Button disabled={disabled} onClick={onClick} type="submit">Start</Button>
  )
}

export default function Page() {
  const [summary, setSummary] = useState<string | null>(null)
  const [targetTaskId, setTargetTaskId] = useState<string | null>(null)
  const [targetApproachId, setTargetApproachId] = useState<string | null>(null)

  const summaryOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  const taskOnChange = useCallback(
    (approachId: string | null) => {
      if (approachId == null) {
        setTargetApproachId('')
      } else {
        setTargetApproachId(approachId)
      }
    },
    [setTargetApproachId],
  )

  const searchTasks = useCallback(
    async (searchString: string) => taskService.list(searchString),
    [],
  )

  const disabled = !summary || !targetApproachId || summary.length === 0
    || targetApproachId.length === 0

  return (
    <Box>
      <TitleAndButton title="Start a queue">
        <AddButton
          disabled={disabled}
          summary={summary || ''}
          targetApproachId={targetApproachId}
        />
        {' or '}
        <Link href="/learning/queues">cancel</Link>
      </TitleAndButton>

      <TextInput
        mb={20}
        onChange={summaryOnChange}
        placeholder="Name of queue"
        label="Name"
        type="text"
        value={summary || ''}
      />

      <TaskApproachSelect
        approachId={targetApproachId}
        setApproachId={taskOnChange}
        taskId={targetTaskId}
        setTaskId={setTargetTaskId}
        searchTasks={searchTasks}
      />
    </Box>
  )
}
