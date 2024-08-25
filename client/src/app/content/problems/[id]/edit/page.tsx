'use client'

import React, { ChangeEvent, useCallback, useState } from 'react'
import problemService from '@/services/problems'
import { Problem } from '@/types'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Button, Textarea, TextInput } from '@mantine/core'
import classes from './page.module.css'

type SaveButtonProps = {
  disabled: boolean,
  problemId: string,
  questionText: string | null,
  questionUrl: string | null,
  summary: string,
}

function SaveButton({
  disabled, summary, problemId, questionText, questionUrl,
}: SaveButtonProps) {
  const router = useRouter()

  const onClick = useCallback(
    async () => {
      const res = await problemService.put(problemId, { summary, questionText, questionUrl })

      if (!res.ok) {
        throw Error(`failed to save problem: ${res}`)
      }

      router.push(`/content/problems/${problemId}`)
    },
    [problemId, summary, questionText, questionUrl, router],
  )

  return (
    <Button type="submit" onClick={onClick} disabled={disabled}>Save</Button>
  )
}

function EditForm({ problem }: { problem: Problem }) {
  const [summary, setSummary] = useState(problem.summary)
  const [questionText, setQuestionText] = useState(problem.questionText || '')
  const [questionUrl, setQuestionUrl] = useState(problem.questionUrl || '')

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
          problemId={problem.id}
          questionText={questionText}
          questionUrl={questionUrl}
          summary={summary}
        />
        {' or '}
        <Link href={`/content/problems/${problem.id}`}>cancel</Link>
      </div>
    </div>
  )
}

type Params = {
  params?: { id: string } | null
}

// eslint-disable-next-line @next/next/no-async-client-component
export default async function Page(params: Params) {
  const problemId = params?.params?.id
  if (problemId == null) {
    return <div>Loading ...</div>
  }

  const problem = (await problemService.get(problemId)).data
  if (problem == null) {
    return (
      <div>
        Problem not found:
        {problemId}
      </div>
    )
  }

  return (
    <main>
      <h1>Update problem</h1>
      <EditForm problem={problem} />
    </main>
  )
}
