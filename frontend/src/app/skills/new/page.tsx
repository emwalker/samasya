"use client";

import { useState, useCallback } from "react"
import { useRouter } from "next/navigation"

type Skill = {
  description: string,
}

function AddButton({ skill }: { skill: Skill }) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    console.log(`Submitting a request to the server to add a skill: ${skill.description}`)
    const res = await fetch('http://localhost:8000/api/v1/skills', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(skill),
    })

    if (res.ok) {
      router.push('/skills')
    }
  }, [skill, router])

  return (
    <button onClick={onClick} type="submit">Add</button>
  )
}

export default function Page() {
  const [description, setDescription] = useState("")

  const onChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => setDescription(event.target.value),
  [setDescription])

  return (
    <main>
      <div>
        <h1>Add a skill</h1>

        <p>
          <input
            type="text"
            placeholder="Description"
            value={description}
            onChange={onChange}
          />
        </p>

        <p>
          <AddButton skill={{ description }} />
        </p>
      </div>
    </main>
  )
}
