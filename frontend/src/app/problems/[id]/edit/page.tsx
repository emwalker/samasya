'use client'

import React, {
  useCallback, useState,
} from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import SkillMultiSelect from '@/components/SkillMultiSelect'
import PrerequisiteProblemList from '@/components/PrerequisiteProblemList'
import { Skill, Problem } from '@/types'
import { getProblem, putProblem, ProblemUpdate } from '@/services/problems'
import styles from './style.module.css'

type SaveButtonProps = {
  description: string,
  disabled: boolean,
  id: string,
  prequisiteSkills: Skill[],
  prerequisiteProblems: Problem[],
}

function SaveButton({
  disabled, id, description, prequisiteSkills, prerequisiteProblems,
}: SaveButtonProps) {
  const router = useRouter()
  const prerequisiteSkillIds = prequisiteSkills.map(({ id }) => id)
  const prerequisiteProblemIds = prerequisiteProblems.map(({ id }) => id)

  const onClick = useCallback(async () => {
    const update: ProblemUpdate = {
      description,
      prerequisiteProblemIds,
      prerequisiteSkillIds,
    }
    const res = await putProblem({ id, update })

    if (res.ok) {
      router.push(`/problems/${id}`)
    }
  }, [id, description, prerequisiteProblemIds, prerequisiteSkillIds, router])

  return (
    <button disabled={disabled} onClick={onClick} type="submit">Update</button>
  )
}

type Params = {
  params?: { id: string } | null
}

function EditForm({ problem }: { problem: Problem }) {
  const {
    id, description: initialDescription, prerequisiteSkills: initialSkills,
    prerequisiteProblems: initialProblems,
  } = problem
  const [description, setDescription] = useState(initialDescription)
  const [prequisiteSkills, setPrerequisiteSkills] = useState(initialSkills)
  const [prerequisiteProblems, setPrerequisiteProblems] = useState(initialProblems)

  const descOnChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => setDescription(event.target.value || ''),
    [setDescription],
  )

  const disabled = description.length === 0

  return (
    <div className={styles.editForm}>
      <p>
        <textarea
          cols={100}
          defaultValue={description || problem.description}
          onChange={descOnChange}
          rows={6}
        />
      </p>

      <div>
        <SkillMultiSelect
          initialPrerequisiteSkills={initialSkills}
          setPrerequisiteSkills={setPrerequisiteSkills}
        />
      </div>

      <div>
        <PrerequisiteProblemList
          prerequisiteProblems={prerequisiteProblems}
          setPrerequisiteProblems={setPrerequisiteProblems}
        />
      </div>

      <p>
        <SaveButton
          description={description}
          disabled={disabled}
          id={id}
          prequisiteSkills={prequisiteSkills}
          prerequisiteProblems={prerequisiteProblems}
        />
        {' or '}
        <Link href={`/problems/${id}`}>cancel</Link>
      </p>
    </div>
  )
}

export default async function Page(params: Params) {
  if (params?.params == null) {
    return <div>Loading ...</div>
  }

  const { id } = params.params
  const problem = (await getProblem({ id })).data
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
