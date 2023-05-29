'use client'

import React, {
  ChangeEvent,
  useCallback, useState,
} from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import SkillMultiSelect from '@/components/SkillMultiSelect'
import PrereqApproachList from '@/components/PrereqApproachList'
import { Skill, WideApproach, Approach } from '@/types'
import approachService from '@/services/approaches'
import styles from './style.module.css'

type SaveButtonProps = {
  disabled: boolean,
  id: string,
  name: string,
  prereqApproaches: Approach[],
  prereqSkills: Skill[],
  problemId: string,
}

function SaveButton({
  disabled, id, problemId, name, prereqSkills, prereqApproaches,
}: SaveButtonProps) {
  const router = useRouter()
  const prereqSkillIds = prereqSkills.map(({ id }) => id)
  const prereqApproachIds = prereqApproaches.map(({ id }) => id)

  const onClick = useCallback(async () => {
    const res = await approachService.put(id, {
      name, problemId, prereqApproachIds, prereqSkillIds,
    })

    if (res.ok) {
      router.push(`/problems/${problemId}`)
    }
  }, [id, name, problemId, prereqApproachIds, prereqSkillIds, router])

  return (
    <button disabled={disabled} onClick={onClick} type="submit">Update</button>
  )
}

type Params = {
  params?: { id: string } | null
}

function EditForm({ approach }: { approach: WideApproach }) {
  const {
    id,
    name: initialName,
    prereqSkills: initialSkills,
    prereqApproaches: initialApproaches,
  } = approach
  const [name, setName] = useState(initialName)
  const [prereqSkills, setPrerequisiteSkills] = useState(initialSkills)
  const [prereqApproaches, setPrereqApproaches] = useState(initialApproaches)

  const nameOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setName(event.target.value),
    [setName],
  )

  return (
    <div className={styles.editForm}>
      <p>
        {approach.summary}
      </p>

      <div>
        <input
          type="text"
          size={100}
          value={name}
          placeholder="Name of approach"
          onChange={nameOnChange}
        />
      </div>

      <div>
        <SkillMultiSelect
          initialPrerequisiteSkills={initialSkills}
          setPrerequisiteSkills={setPrerequisiteSkills}
        />
      </div>

      <div>
        <PrereqApproachList
          prereqApproaches={prereqApproaches}
          setPrereqApproaches={setPrereqApproaches}
        />
      </div>

      <p>
        <SaveButton
          disabled={false}
          id={id}
          name={name}
          prereqApproaches={prereqApproaches}
          prereqSkills={prereqSkills}
          problemId={approach.problem.id}
        />
        {' or '}
        <Link href={`/problems/${approach.problem.id}`}>cancel</Link>
      </p>
    </div>
  )
}

export default async function Page(params: Params) {
  if (params?.params == null) {
    return <div>Loading ...</div>
  }

  const { id } = params.params
  const approach = (await approachService.get(id)).data
  if (approach == null) {
    return (
      <div>
        Approach not found:
        {id}
      </div>
    )
  }

  return (
    <main>
      <div>
        <h1>
          Update approach
        </h1>

        <EditForm approach={approach} />
      </div>
    </main>
  )
}
