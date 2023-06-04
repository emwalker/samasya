'use client'

import React, { useState, useCallback, ChangeEvent } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import queueService from '@/services/queues'
import contants from '@/constants'
import ProblemList from '@/components/ProblemList'
import { ProblemSlice, QueueStrategy } from '@/types'

type AddButtonProps = {
  disabled: boolean,
  summary: string,
  targetProblemId: string,
}

function AddButton({ disabled, summary, targetProblemId }: AddButtonProps) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    const res = await queueService.post(
      contants.placeholderUserId,
      { summary, targetProblemId, strategy: QueueStrategy.SpacedRepetitionV1 },
    )

    if (res.ok) {
      router.push('/learning/queues')
    }
  }, [summary, targetProblemId, router])

  return (
    <button disabled={disabled} onClick={onClick} type="submit">Start</button>
  )
}

export default function Page() {
  const [summary, setSummary] = useState('')
  const [targetProblemId, setTargetProblemId] = useState('')

  const summaryOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  const problemOnChange = useCallback(
    (problem: ProblemSlice | null) => {
      if (problem == null) {
        if (summary === '') {
          setSummary('')
        }
        setTargetProblemId('')
      } else {
        if (summary === '') {
          setSummary(problem.summary)
        }
        setTargetProblemId(problem.id)
      }
    },
    [setTargetProblemId, summary, setSummary],
  )

  const disabled = summary.length === 0 || targetProblemId.length === 0

  return (
    <main>
      <div>
        <h1>Start a problem queue</h1>

        <p>
          <input
            onChange={summaryOnChange}
            placeholder="Name for the problem queue"
            size={100}
            type="text"
            value={summary}
          />
        </p>

        <div>
          <ProblemList
            initialProblems={[]}
            label="Problem to work towards"
            setProblem={problemOnChange}
          />
        </div>

        <p>
          <AddButton
            disabled={disabled}
            summary={summary}
            targetProblemId={targetProblemId}
          />
          {' or '}
          <Link href="/learning/queues">cancel</Link>
        </p>
      </div>
    </main>
  )
}
