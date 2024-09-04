'use client'

import React, {
  ChangeEvent, useCallback, useEffect, useState,
} from 'react'
import taskService, { FetchData } from '@/services/tasks'
import { TaskType } from '@/types'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import {
  Box, Button, LoadingOverlay, Textarea, TextInput,
} from '@mantine/core'
import classes from './page.module.css'

type SaveButtonProps = {
  disabled: boolean,
  taskId: string,
  questionText: string | null,
  questionUrl: string | null,
  summary: string,
}

function SaveButton({
  disabled, summary, taskId, questionText, questionUrl,
}: SaveButtonProps) {
  const router = useRouter()

  const onClick = useCallback(
    async () => {
      const res = await taskService.update(taskId, { summary, questionText, questionUrl })

      if (!res.ok) {
        throw Error(`failed to save problem: ${res}`)
      }

      router.push(`/content/tasks/${taskId}`)
    },
    [taskId, summary, questionText, questionUrl, router],
  )

  return (
    <Button type="submit" onClick={onClick} disabled={disabled}>Save</Button>
  )
}

function EditForm({ task }: { task: TaskType }) {
  const [summary, setSummary] = useState(task.summary)
  const [questionText, setQuestionText] = useState(task.questionText || '')
  const [questionUrl, setQuestionUrl] = useState(task.questionUrl || '')

  const summaryOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  const questionTextOnChange = useCallback(
    (event: ChangeEvent<HTMLTextAreaElement>) => setQuestionText(event.target.value),
    [setQuestionText],
  )

  const questionUrlOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setQuestionUrl(event.target.value),
    [setQuestionUrl],
  )

  const questionTextExists = questionText.length > 0
  const questionUrlExists = questionUrl.length > 0
  const disabled = summary.length === 0 || (questionTextExists && questionUrlExists)
    || (!questionTextExists && !questionUrlExists)

  return (
    <div>
      <TextInput
        className={classes.input}
        id="summary"
        label="Summary"
        onChange={summaryOnChange}
        placeholder="Short summary of problem"
        type="text"
        value={summary || ''}
      />

      <Textarea
        className={classes.input}
        cols={100}
        disabled={questionUrlExists}
        id="question-text"
        label="Question prompt"
        onChange={questionTextOnChange}
        placeholder="Question prompt to be shown"
        rows={6}
        value={questionText || ''}
      />

      <TextInput
        className={classes.input}
        disabled={questionTextExists}
        id="question-url"
        label="Question url"
        onChange={questionUrlOnChange}
        placeholder="Link to another website"
        type="text"
        value={questionUrl || ''}
      />

      <p>
        <small>Either a question prompt or a question url should be provided, but not both.</small>
      </p>

      <div>
        <SaveButton
          disabled={disabled}
          taskId={task.id}
          questionText={questionText}
          questionUrl={questionUrl}
          summary={summary}
        />
        {' or '}
        <Link href={`/content/problems/${task.id}`}>cancel</Link>
      </div>
    </div>
  )
}

type Params = {
  params?: { id: string } | null
}

export default function Page(params: Params) {
  const [isLoading, setIsLoading] = useState(true)
  const [fetchData, setFetchData] = useState<FetchData | null>(null)
  const problemId = params?.params?.id

  useEffect(() => {
    async function loadData() {
      if (problemId == null) return
      const currResponse = await taskService.fetch(problemId)
      setFetchData(currResponse?.data || null)
      setIsLoading(false)
    }
    loadData()
  }, [problemId, setIsLoading, setFetchData])

  const task = fetchData?.task

  return (
    <main>
      <Box pos="relative">
        <LoadingOverlay
          visible={isLoading}
          zIndex={1000}
          overlayProps={{ radius: 'sm', blur: 2 }}
        />

        {task && <EditForm task={task} />}
      </Box>
    </main>
  )
}
