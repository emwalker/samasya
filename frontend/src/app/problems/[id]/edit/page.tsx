'use client'

import React, {
  useCallback, useState,
} from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import SkillDropdown, { Skill } from '../../SkillDropdown'

type Problem = {
  id: string,
  description: string,
  skills: Skill[]
}

type Response = {
  data: Problem | null
}

type SaveButtonProps = {
  description: string,
  disabled: boolean,
  id: string,
  skills: Skill[],
}

function SaveButton({
  disabled, id, description, skills,
}: SaveButtonProps) {
  const router = useRouter()
  const skillIds = skills.map(({ id }) => id)

  const onClick = useCallback(async () => {
    const problemUpdate = { description, skillIds }
    const res = await fetch(`http://localhost:8000/api/v1/problems/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(problemUpdate),
    })

    if (res.ok) {
      router.push(`/problems/${id}`)
    }
  }, [id, description, skillIds, router])

  return (
    <button disabled={disabled} onClick={onClick} type="submit">Update</button>
  )
}

async function getData({ id }: { id: string }): Promise<Response> {
  const res = await fetch(`http://localhost:8000/api/v1/problems/${id}`, { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: null })
  }

  return res.json()
}

type Params = {
  params?: { id: string } | null
}

function EditForm({ problem }: { problem: Problem }) {
  const { id, description: initialDescription, skills: initialSkills } = problem
  const [description, setDescription] = useState(initialDescription)
  const [skills, setSkills] = useState(initialSkills)

  const descOnChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => setDescription(event.target.value || ''),
    [setDescription],
  )

  const disabled = description.length === 0

  return (
    <>
      <p>
        <textarea
          cols={100}
          defaultValue={description || problem.description}
          onChange={descOnChange}
          rows={6}
        />
      </p>

      <div>
        <SkillDropdown initialSkills={initialSkills} setSkills={setSkills} />
      </div>

      <p>
        <SaveButton disabled={disabled} id={id} skills={skills} description={description} />
        {' or '}
        <Link href={`/problems/${id}`}>cancel</Link>
      </p>
    </>
  )
}

export default async function Page(params: Params) {
  if (params?.params == null) {
    return <div>Loading ...</div>
  }

  const { id } = params.params
  const problem = (await getData({ id })).data
  if (problem == null) {
    return (
      <div>
        Problem not found:
        {id}
      </div>
    )
  }

  return (
    <main>
      <div>
        <h1>
          Update problem
        </h1>

        <EditForm problem={problem} />
      </div>
    </main>
  )
}
