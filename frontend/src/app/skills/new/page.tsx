'use client'

import React, { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { postSkill } from '@/services/skills'

function AddButton({ description }: { description: string }) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    const update = { description }
    const res = await postSkill({ update })

    if (res.ok) {
      router.push('/skills')
    }
  }, [description, router])

  return (
    <button onClick={onClick} type="submit">Add</button>
  )
}

export default function Page() {
  const [description, setDescription] = useState('')

  const onChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => setDescription(event.target.value),
    [setDescription],
  )

  return (
    <main>
      <div>
        <h1>Add a skill</h1>

        <p>
          <textarea
            cols={80}
            rows={3}
            placeholder="Description"
            value={description}
            onChange={onChange}
          />
        </p>

        <p>
          <AddButton description={description} />
        </p>
      </div>
    </main>
  )
}
