'use client'

import React, { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import skillService from '@/services/skills'
import Link from 'next/link'
import { Button, Textarea } from '@mantine/core'

function AddButton({ description, disabled }: { description: string, disabled: boolean }) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    const res = await skillService.post({ description })

    if (res.ok) {
      router.push('/content/skills')
    }
  }, [description, router])

  return (
    <Button disabled={disabled} onClick={onClick} type="submit">Add</Button>
  )
}

export default function Page() {
  const [description, setDescription] = useState('')

  const onChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => setDescription(event.target.value),
    [setDescription],
  )

  const disabled = description.length === 0

  return (
    <main>
      <div>
        <h1>Add a skill</h1>

        <Textarea
          cols={80}
          rows={3}
          placeholder="Description"
          value={description}
          onChange={onChange}
        />

        <p>
          <AddButton disabled={disabled} description={description} />
          {' or '}
          <Link href="/content/skills">cancel</Link>
        </p>
      </div>
    </main>
  )
}
