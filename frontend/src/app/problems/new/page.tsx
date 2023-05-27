'use client'

import React, { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import SkillDropdown, { Skill } from '../SkillDropdown'

type Problem = {
  description: string,
  skills: Skill[]
}

type AddButtonProps = { disabled: boolean, problem: Problem }

function AddButton({ disabled, problem: { description, skills } }: AddButtonProps) {
  const router = useRouter()
  const skillIds = skills.map(({ id }) => id)

  const onClick = useCallback(async () => {
    const problemUpdate = { description, skillIds }

    const res = await fetch('http://localhost:8000/api/v1/problems', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(problemUpdate),
    })

    if (res.ok) {
      router.push('/problems')
    }
  }, [description, skillIds, router])

  return (
    <button disabled={disabled} onClick={onClick} type="submit">Add</button>
  )
}

export default function Page() {
  const [description, setDescription] = useState('')
  const [skills, setSkills] = useState([] as Skill[])

  const descOnChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => setDescription(event.target.value),
    [setDescription],
  )

  const disabled = description.length === 0

  return (
    <main>
      <div>
        <h1>Add a problem</h1>

        <p>
          <textarea
            cols={100}
            onChange={descOnChange}
            placeholder="Description"
            rows={6}
            value={description}
          />
        </p>

        <div>
          <SkillDropdown initialSkills={[]} setSkills={setSkills} />
        </div>

        <p>
          <AddButton disabled={disabled} problem={{ description, skills }} />
          {' or '}
          <Link href="/problems">cancel</Link>
        </p>
      </div>
    </main>
  )
}
