'use client'

import React, { useState, useCallback, ChangeEvent } from 'react'
import { useRouter } from 'next/navigation'
import skillService from '@/services/skills'
import Link from 'next/link'
import {
  Box, Button, Textarea, TextInput,
} from '@mantine/core'
import TitleAndButton from '@/components/TitleAndButton'

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
    (event: ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  const descriptionOnChange = useCallback(
    (event: ChangeEvent<HTMLTextAreaElement>) => setDescription(event.target.value),
    [setDescription],
  )

  const disabled = description.length === 0

  return (
    <Box>
      <TitleAndButton title="Add a skill">
        <AddButton disabled={disabled} summary={summary} description={description} />
        {' or '}
        <Link href="/content/skills">cancel</Link>
      </TitleAndButton>

      <TextInput
        mb={10}
        placeholder="Short summary that can be shown in lists"
        label="Summary"
        defaultValue={description}
        onChange={summaryOnChange}
      />

      <Textarea
        cols={80}
        rows={3}
        label="Description"
        placeholder="Go into further detail about what the skill involves"
        defaultValue={description}
        onChange={descriptionOnChange}
      />
    </Box>
  )
}
