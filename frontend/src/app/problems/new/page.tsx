'use client'

import React, { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import AsyncSelect from 'react-select/async'
import { MultiValue } from 'react-select'

type Skill = {
  id: string,
  description: string,
}

type Option = {
  value: string,
  label: string,
}

type Problem = {
  description: string,
  skillIds: string[]
}

function AddButton({ disabled, problem }: { disabled: boolean, problem: Problem }) {
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
    <button disabled={disabled} onClick={onClick} type="submit">Add</button>
  )
}

async function fetchSkills(searchText: string): Promise<Option[]> {
  const response = await fetch(`http://localhost:8000/api/v1/skills?q=${searchText}`)
  if (!response.ok) {
    return []
  }
  const data = (await response.json()).data as Skill[]
  return data.map(({ id, description }) => ({ value: id, label: description }))
}

const components = {
  NoOptionsMessage: () => <div>No skills</div>,
  LoadingMessage: () => <div>Loading ...</div>,
  LoadingIndicator: () => null,
}

export default function Page() {
  const [description, setDescription] = useState('')
  const [skillIds, setSkills] = useState([] as string[])

  const descOnChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => setDescription(event.target.value),
    [setDescription],
  )

  const skillsOnChange = useCallback(
    (newValue: MultiValue<Option>) => setSkills(newValue.map(({ value }) => value)),
    [setSkills],
  )

  const skillsLoadOptions = useCallback(fetchSkills, [fetchSkills])
  const addButtonDisabled = skillIds.length === 0 || description.length === 0

  return (
    <main>
      <div>
        <h1>Add a problem</h1>

        <p>
          <input
            type="text"
            placeholder="Description"
            value={description}
            onChange={descOnChange}
          />
        </p>

        <div>
          <AsyncSelect
            cacheOptions
            components={components}
            defaultOptions
            instanceId="skill-dropdown"
            isMulti
            loadOptions={skillsLoadOptions}
            onChange={skillsOnChange}
          />
        </div>

        <p>
          <AddButton disabled={addButtonDisabled} problem={{ description, skillIds }} />
          {' '}
          <Link href="/problems">Cancel</Link>
        </p>
      </div>
    </main>
  )
}
