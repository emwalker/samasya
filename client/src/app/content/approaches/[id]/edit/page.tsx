'use client'

import React, {
  ChangeEvent,
  useCallback, useState,
} from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import PrereqApproachList from '@/components/PrereqApproachList'
import { SkillType, WideApproach, ApproachType } from '@/types'
import approachService from '@/services/approaches'
import styles from './style.module.css'

type SaveButtonProps = {
  disabled: boolean,
  id: string,
  name: string,
  prereqApproaches: ApproachType[],
  prereqSkills: SkillType[],
  problemId: string,
}

function SaveButton({
  disabled, id, problemId, name, prereqSkills, prereqApproaches,
}: SaveButtonProps) {
  const router = useRouter()
  const prereqSkillIds = prereqSkills.map(({ id: id_ }) => id_)
  const prereqApproachIds = prereqApproaches.map(({ id: id_ }) => id_)

  const onClick = useCallback(async () => {
    const res = await approachService.put(id, {
      name, problemId, prereqApproachIds, prereqSkillIds,
    })

    if (res.ok) {
      router.push(`/content/problems/${problemId}`)
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
    prereqTasks: initialTasks,
    prereqApproaches: initialApproaches,
  } = approach
  const [name, setName] = useState(initialName)
  const [prereqSkills] = useState(initialTasks)
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
        Select task
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
        <Link href={`/content/problems/${approach.problem.id}`}>cancel</Link>
      </p>
    </div>
  )
}

// eslint-disable-next-line @next/next/no-async-client-component
export default async function Page(params: Params) {
  if (params?.params == null) {
    return <div>Loading ...</div>
  }

  const { params: { id } } = params
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
