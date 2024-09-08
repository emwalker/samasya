'use client'

import React, { useState, useCallback, ChangeEvent } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import taskService, { AddPayload } from '@/services/tasks'
import {
  Box,
  Button,
  Group,
  Select,
  Textarea,
  TextInput,
} from '@mantine/core'
import { placeholderRepoId } from '@/constants'
import { handleError } from '@/app/handleResponse'
import { notifications } from '@mantine/notifications'
import TitleAndButton from '@/components/TitleAndButton'
import { TaskAction, taskActions } from '@/types'
import { actionText } from '@/helpers'

const actionOptions = taskActions.map((action) => ({ value: action, label: actionText(action) }))

type AddButtonProps = {
  disabled: boolean,
  summary: string,
  questionPrompt: string | null,
  questionUrl: string | null,
}

function AddButton({
  disabled,
  questionPrompt,
  questionUrl,
  summary,
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
  const [action, setAction] = useState<TaskAction>('completeProblem')

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

  const actionOnChange = useCallback((value: string | null) => {
    setAction(value || 'completeProblem')
  }, [setAction])

  const disabled = summary.length === 0
  const questionUrlExists = questionUrl.length > 0
  const questionTextExists = questionText.length > 0

  return (
    <Box>
      <TitleAndButton title={`Add ${actionText(action).toLocaleLowerCase()}`}>
        <Group>
          <AddButton
            disabled={disabled}
            summary={summary}
            questionUrl={questionUrl}
            questionPrompt={questionText}
          />
          {' or '}
          <Link href="/content/problems">cancel</Link>
        </Group>
      </TitleAndButton>

      <Select
        mt={20}
        data={actionOptions}
        defaultValue={action}
        onChange={actionOnChange}
      />

      <TextInput
        mt={20}
        onChange={summaryOnChange}
        placeholder="Short summary of task that can be shown in lists"
        type="text"
        value={summary}
      />

      <TextInput
        mt={20}
        onChange={questionUrlOnChange}
        placeholder="Question url"
        type="text"
        disabled={questionTextExists}
        value={questionUrl}
      />

      <Textarea
        mt={20}
        cols={100}
        onChange={questionTextOnChange}
        placeholder="Question prompt"
        rows={6}
        disabled={questionUrlExists}
        value={questionText}
      />

      <small>Either a link or a prompt can be provided, but not both.</small>
    </Box>
  )
}
