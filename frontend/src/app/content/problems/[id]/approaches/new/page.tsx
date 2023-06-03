'use client'

import React, { useCallback, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import problemService from '@/services/problems'
import approachService from '@/services/approaches'
import { WideProblem, Skill } from '@/types'
import SkillMultiSelect from '@/components/SkillMultiSelect'

type Params = {
  params: { id: string } | null
}

type AddButtonProps = {
  disabled: boolean,
  name: string,
  problemId: string,
  prereqSkills: Skill[]
}

function AddButton({
  problemId, disabled, name, prereqSkills,
}: AddButtonProps) {
  const router = useRouter()
  const prereqSkillIds = prereqSkills.map(({ id }) => id)

  const onClick = useCallback(async () => {
    const res = await approachService.post({
      prereqApproachIds: [], prereqSkillIds, name, problemId,
    })

    if (res.ok) {
      router.push(`/content/problems/${problemId}`)
    }
  }, [problemId, name, prereqSkillIds, router])

  return (
    <button disabled={disabled} onClick={onClick} type="submit">Add</button>
  )
}

function NewApproachForm({ problem }: { problem: WideProblem }) {
  const [name, setName] = useState('')
  const [prereqSkills, setPrerequisiteSkills] = useState([] as Skill[])

  const nameOnChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => setName(event.target.value),
    [setName],
  )

  const disabled = name.length === 0

  return (
    <div>
      <h1>Add an approach</h1>

      <div>
        Problem:
        {problem.summary}
      </div>

      <p>
        <input
          size={100}
          onChange={nameOnChange}
          placeholder="Name of approach"
          value={name}
        />
      </p>

      <div>
        <SkillMultiSelect
          initialPrerequisiteSkills={[]}
          setPrerequisiteSkills={setPrerequisiteSkills}
        />
      </div>

      <p>
        <AddButton
          disabled={disabled}
          name={name}
          problemId={problem.id}
          prereqSkills={prereqSkills}
        />
        {' or '}
        <Link href={`/content/problems/${problem.id}`}>cancel</Link>
      </p>
    </div>
  )
}

export default async function Page(params: Params) {
  const problemId = params?.params?.id
  if (problemId == null) {
    return <div>Loading ...</div>
  }

  const problem = (await problemService.get(problemId)).data
  if (problem == null) {
    return (
      <div>
        Problem not found:
        {problemId}
      </div>
    )
  }

  return (
    <main>
      <NewApproachForm problem={problem} />
    </main>
  )
}
