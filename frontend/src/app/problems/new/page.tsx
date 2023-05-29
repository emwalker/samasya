'use client'

import React, { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import problemService from '@/services/problems'

type AddButtonProps = {
  disabled: boolean,
  questionText: string,
}

function AddButton({ disabled, questionText }: AddButtonProps) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    const res = await problemService.post({ questionText })

    if (res.ok) {
      router.push('/problems')
    }
  }, [questionText, router])

  return (
    <button disabled={disabled} onClick={onClick} type="submit">Add</button>
  )
}

export default function Page() {
  const [questionText, setQuestionText] = useState('')

  const questionTextOnChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => setQuestionText(event.target.value),
    [setQuestionText],
  )

  const disabled = questionText.length === 0

  return (
    <main>
      <div>
        <h1>Add a problem</h1>

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
            questionText={questionText}
          />
          {' or '}
          <Link href="/problems">cancel</Link>
        </p>
      </div>
    </main>
  )
}
