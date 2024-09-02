'use client'

import React, {
  useState, useCallback, ChangeEvent, useEffect,
} from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import queueService from '@/services/queues'
import contants from '@/constants'
import AvailableTasks from '@/components/AvailableTasks'
import taskService from '@/services/tasks'
import { Button, ComboboxData, TextInput } from '@mantine/core'
import handleResponse from '@/app/handleResponse'

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
      { summary, targetTaskId: targetTaskId, strategy: 'spacedRepetitionV1' },
    )

    handleResponse(router, response, '/learning/queues', 'Unable to add queue')
  }, [summary, targetTaskId, router])

  return (
    <Button disabled={disabled} onClick={onClick} type="submit">Start</Button>
  )
}

export default function Page() {
  const [summary, setSummary] = useState('')
  const [targetTaskId, setTargetProblemId] = useState('')
  const [initialProblems, setInitialProblems] = useState<ComboboxData>([])

  const summaryOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  useEffect(() => {
    taskService.list()
      .then(({ data }) => {
        const options = data.map(({ id: value, summary: label }) => ({ value, label }))
        setInitialProblems(options)
      })
  }, [setInitialProblems])

  const taskOnChange = useCallback(
    (problemId: string | null) => {
      if (problemId == null) {
        setTargetProblemId('')
      } else {
        setTargetProblemId(problemId)
      }
    },
    [setTargetProblemId],
  )

  const disabled = summary.length === 0 || targetTaskId.length === 0

  return (
    <main>
      <div>
        <h1>Start a queue</h1>

        <TextInput
          onChange={summaryOnChange}
          placeholder="Name of queue"
          label="Name"
          type="text"
          value={summary}
        />
        <br />

        <div>
          <AvailableTasks
            initialProblems={initialProblems}
            label="Challenge to work towards"
            setProblem={taskOnChange}
          />
        </div>

        <p>
          <AddButton
            disabled={disabled}
            summary={summary}
            targetProblemId={targetTaskId}
          />
          {' or '}
          <Link href="/learning/queues">cancel</Link>
        </p>
      </div>
    </main>
  )
}
