'use client'

import React, { useState, useCallback, ChangeEvent } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import problemService from '@/services/problems'
import { Button, Textarea, TextInput } from '@mantine/core'
import classes from './page.module.css'

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
    const res = await problemService.add({ summary, questionText, questionUrl })

    if (res.ok) {
      router.push('/content/problems')
    }
  }, [summary, questionText, questionUrl, router])

  return (
    <Button disabled={disabled} onClick={onClick} type="submit">Add</Button>
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
  const questionUrlExists = questionUrl.length > 0
  const questionTextExists = questionText.length > 0

  return (
    <main>
      <div>
        <h1>Add a problem</h1>

        <div className={classes.input}>
          <TextInput
            onChange={summaryOnChange}
            placeholder="Short summary of the problem"
            type="text"
            value={summary}
          />
        </div>

        <div className={classes.input}>
          <TextInput
            onChange={questionUrlOnChange}
            placeholder="Question url"
            type="text"
            disabled={questionTextExists}
            value={questionUrl}
          />
        </div>

        <div className={classes.input}>
          <Textarea
            cols={100}
            onChange={questionTextOnChange}
            placeholder="Question prompt"
            rows={6}
            disabled={questionUrlExists}
            value={questionText}
          />
        </div>

        <div className={classes.input}>
          <AddButton
            disabled={disabled}
            summary={summary}
            questionUrl={questionUrl}
            questionText={questionText}
          />
          {' or '}
          <Link href="/content/problems">cancel</Link>
        </div>
      </div>
    </main>
  )
}
