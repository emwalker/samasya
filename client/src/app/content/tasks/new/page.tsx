'use client'

import React, { useState, useCallback, ChangeEvent } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import taskService, { AddPayload } from '@/services/tasks'
import { Button, Textarea, TextInput } from '@mantine/core'
import { placeholderRepoId } from '@/constants'
import { handleError } from '@/app/handleResponse'
import { notifications } from '@mantine/notifications'
import classes from './page.module.css'

type AddButtonProps = {
  disabled: boolean,
  summary: string,
  questionPrompt: string | null,
  questionUrl: string | null,
}

function AddButton({
  disabled, summary, questionPrompt, questionUrl,
}: AddButtonProps) {
  const router = useRouter()
  const repoId = placeholderRepoId

  const onClick = useCallback(async () => {
    const payload: AddPayload = {
      repoId, summary, action: 'completeProblem', questionPrompt, questionUrl,
    }
    const response = await taskService.add(repoId, payload)
    const addedTaskId = response?.data?.addedTaskId || null

    if (addedTaskId != null) {
      notifications.show({
        title: 'Task added',
        message: 'A new task has been added',
        position: 'top-center',
        color: 'blue',
      })
      router.push(`/api/v1/tasks/${addedTaskId}`)
    } else {
      handleError(response, 'Failed to add task')
    }
  }, [repoId, summary, questionPrompt, questionUrl, router])

  return (
    <Button disabled={disabled} onClick={onClick} type="submit">Add</Button>
  )
}

export default function Page() {
  const [summary, setSummary] = useState('')
  const [questionText, setQuestionPrompt] = useState('')
  const [questionUrl, setQuestionUrl] = useState('')

  const summaryOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  const questionTextOnChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => setQuestionPrompt(event.target.value),
    [setQuestionPrompt],
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
            questionPrompt={questionText}
          />
          {' or '}
          <Link href="/content/problems">cancel</Link>
        </div>
      </div>
    </main>
  )
}
