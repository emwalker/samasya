'use client'

import React, { ChangeEvent, useCallback, useState } from 'react'
import problemService from '@/services/problems'
import { Problem } from '@/types'
import { useRouter } from 'next/navigation'
import Link from 'next/link'

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
    <button type="submit" onClick={onClick} disabled={disabled}>Save</button>
  )
}

function EditForm({ problem }: { problem: Problem }) {
  const [summary, setSummary] = useState(problem.summary)
  const [questionText, setQuestionText] = useState(problem.questionText)
  const [questionUrl, setQuestionUrl] = useState(problem.questionUrl)

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

  const disabled = summary.length === 0 || (questionText != null && questionUrl != null)
    || (questionText == null && questionUrl == null)

  return (
    <div>
      <p>
        <label htmlFor="summary">
          Summary
          <br />
          <input
            id="summary"
            onChange={summaryOnChange}
            placeholder="Short summary of problem"
            size={100}
            type="text"
            value={summary || ''}
          />
        </label>
      </p>

      <p>
        <label htmlFor="question-text">
          Question prompt
          <br />
          <textarea
            cols={100}
            id="question-text"
            onChange={questionTextOnChange}
            placeholder="Question prompt to be shown"
            rows={6}
            value={questionText || ''}
          />
        </label>
      </p>

      <p>
        <label htmlFor="question-url">
          Question url
          <br />
          <input
            id="question-url"
            onChange={questionUrlOnChange}
            placeholder="Link to another website"
            size={100}
            type="text"
            value={questionUrl || ''}
          />
        </label>
      </p>

      <p>
        <small>Either a question prompt or a question url should be provided, but not both.</small>
      </p>

      <p>
        <SaveButton
          disabled={disabled}
          problemId={problem.id}
          questionText={questionText}
          questionUrl={questionUrl}
          summary={summary}
        />
        {' or '}
        <Link href={`/content/problems/${problem.id}`}>cancel</Link>
      </p>
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
