'use client'

import React, { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import skillService from '@/services/skills'
import Link from 'next/link'
import { Button, Textarea, TextInput } from '@mantine/core'

type AddButtonProps = {
  summary: string,
  description: string,
  disabled: boolean,
}

function AddButton({ summary, description, disabled }: AddButtonProps) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    const res = await skillService.add({ summary, description })

    if (res.ok) {
      router.push('/content/skills')
    }
  }, [summary, description, router])

  return (
    <Button disabled={disabled} onClick={onClick} type="submit">Add</Button>
  )
}

export default function Page() {
  const [summary, setSummary] = useState('')
  const [description, setDescription] = useState('')

  const summaryOnChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  const descriptionOnChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => setDescription(event.target.value),
    [setDescription],
  )

  const disabled = description.length === 0

  return (
    <main>
      <div>
        <h1>Add a skill</h1>

        <TextInput
          placeholder="Short summary"
          label="Summary"
          value={description}
          onChange={summaryOnChange}
        />

        <Textarea
          cols={80}
          rows={3}
          placeholder="Description"
          value={description}
          onChange={descriptionOnChange}
        />

        <p>
          <AddButton disabled={disabled} summary={summary} description={description} />
          {' or '}
          <Link href="/content/skills">cancel</Link>
        </p>
      </div>
    </main>
  )
}
