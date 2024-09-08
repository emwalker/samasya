'use client'

import React, {
  ChangeEvent, useCallback, useEffect, useState,
} from 'react'
import taskService, { FetchData } from '@/services/tasks'
import { TaskType } from '@/types'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import {
  Box, Button, Group, LoadingOverlay, Textarea, TextInput,
} from '@mantine/core'
import TitleAndButton from '@/components/TitleAndButton'
import { handleError } from '@/app/handleResponse'
import { notifications } from '@mantine/notifications'
import classes from './page.module.css'

type SaveButtonProps = {
  disabled: boolean,
  taskId: string,
  questionPrompt: string | null,
  questionUrl: string | null,
  summary: string,
}

function SaveButton({
  disabled, summary, taskId, questionPrompt, questionUrl,
}: SaveButtonProps) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    const response = await taskService.update(taskId, {
      taskId, summary, questionPrompt, questionUrl,
    })

    if (response?.data === 'ok') {
      notifications.show({
        title: 'Task saved',
        message: 'This task has been saved',
        color: 'blue',
        position: 'top-center',
      })
      router.push(`/content/tasks/${taskId}`)
    } else {
      handleError(response, 'Failed to update task')
    }
  }, [taskId, summary, questionPrompt, questionUrl, router])

  return (
    <Button type="submit" onClick={onClick} disabled={disabled}>Save</Button>
  )
}

type EditFormProps = {
  task: TaskType,
}

function EditForm({ task }: EditFormProps) {
  const [summary, setSummary] = useState(task.summary)
  const [questionPrompt, setQuestionPrompt] = useState(task.questionText || '')
  const [questionUrl, setQuestionUrl] = useState(task.questionUrl || '')

  const summaryOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  const questionPromptOnChange = useCallback(
    (event: ChangeEvent<HTMLTextAreaElement>) => setQuestionPrompt(event.target.value),
    [setQuestionPrompt],
  )

  const questionUrlOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setQuestionUrl(event.target.value),
    [setQuestionUrl],
  )

  const questionPromptExists = questionPrompt.length > 0
  const questionUrlExists = questionUrl.length > 0
  const disabled = summary.length === 0 || (questionPromptExists && questionUrlExists)
    || (!questionPromptExists && !questionUrlExists)

  return (
    <Box>
      <TitleAndButton title={summary || ''}>
        <Group>
          <SaveButton
            disabled={disabled}
            taskId={task.id}
            questionPrompt={questionPrompt}
            questionUrl={questionUrl}
            summary={summary}
          />
          {' or '}
          <Link href={`/content/tasks/${task.id}`}>cancel</Link>
        </Group>
      </TitleAndButton>

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
        onChange={questionPromptOnChange}
        placeholder="Question prompt to be shown"
        rows={6}
        value={questionPrompt || ''}
      />

      <TextInput
        className={classes.input}
        disabled={questionPromptExists}
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
    </Box>
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
