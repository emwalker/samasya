'use client'

import React, { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'

type Skill = {
  description: string,
}

function AddButton({ problem }: { problem: Skill }) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    const res = await fetch('http://localhost:8000/api/v1/problems', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(problem),
    })

    if (res.ok) {
      router.push('/problems')
    }
  }, [problem, router])

  return (
    <button onClick={onClick} type="submit">Add</button>
  )
}

export default function Page() {
  const [description, setDescription] = useState('')

  const onChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => setDescription(event.target.value),
    [setDescription],
  )

  return (
    <main>
      <div>
        <h1>Add a problem</h1>

        <p>
          <input
            type="text"
            placeholder="Description"
            value={description}
            onChange={onChange}
          />
        </p>

        <p>
          <AddButton problem={{ description }} />
        </p>
      </div>
    </main>
  )
}
