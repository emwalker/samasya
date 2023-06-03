'use client'

import React, { useState, useCallback, ChangeEvent } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import problemService from '@/services/problems'

type AddButtonProps = {
  disabled: boolean,
  summary: string,
  questionText: string | null,
  questionUrl: string | null,
}

function AddButton({
  disabled, summary, questionText, questionUrl,
}: AddButtonProps) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    const res = await problemService.post({ summary, questionText, questionUrl })

    if (res.ok) {
      router.push('/content/problems')
    }
  }, [summary, questionText, questionUrl, router])

  return (
    <button disabled={disabled} onClick={onClick} type="submit">Add</button>
  )
}

export default function Page() {
  const [summary, setSummary] = useState('')
  const [questionText, setQuestionText] = useState('')
  const [questionUrl, setQuestionUrl] = useState('')

  const summaryOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  const questionTextOnChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => setQuestionText(event.target.value),
    [setQuestionText],
  )

  const questionUrlOnChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => setQuestionUrl(event.target.value),
    [setQuestionUrl],
  )

  const disabled = summary.length === 0

  return (
    <main>
      <div>
        <h1>Add a problem</h1>

        <p>
          <input
            onChange={summaryOnChange}
            placeholder="Short summary of the problem"
            size={100}
            type="text"
            value={summary}
          />
        </p>

        <p>
          <input
            onChange={questionUrlOnChange}
            placeholder="Question url"
            size={100}
            type="text"
            value={questionUrl}
          />
        </p>

        <p>
          <textarea
            cols={100}
            onChange={questionTextOnChange}
            placeholder="Question prompt"
            rows={6}
            value={questionText}
          />
        </p>

        <p>
          <AddButton
            disabled={disabled}
            summary={summary}
            questionUrl={questionUrl}
            questionText={questionText}
          />
          {' or '}
          <Link href="/content/problems">cancel</Link>
        </p>
      </div>
    </main>
  )
}
