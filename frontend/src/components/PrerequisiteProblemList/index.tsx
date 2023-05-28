import React, { useCallback } from 'react'
import { Problem } from '@/types'
import { getProblem } from '@/services/problems'
import styles from './styles.module.css'

type Props = {
  prerequisiteProblems: Problem[],
  setPrerequisiteProblems: (problems: Problem[]) => void,
}

type MakeRemoveOnClickProps = Props & {
  id: string
}

type PrereqProps = MakeRemoveOnClickProps & {
  description: string,
}

function Prereq({
  id, description, prerequisiteProblems, setPrerequisiteProblems,
}: PrereqProps) {
  const onClick = useCallback(
    () => {
      const index = prerequisiteProblems.findIndex(({ id: otherId }) => otherId === id)

      if (index > -1) {
        const problems = [...prerequisiteProblems]
        problems.splice(index, 1)
        setPrerequisiteProblems(problems)
      }
    },
    [id, prerequisiteProblems, setPrerequisiteProblems],
  )

  return (
    <li>
      {description}
      {' '}
      <button type="button" onClick={onClick}>remove</button>
    </li>
  )
}

type AddPrereqProps = Props & {
  url: string,
}

function parseIdFromUrl(url: string) {
  return url.replace('/edit', '').split('/').pop()
}

async function addPrereq({ url, prerequisiteProblems, setPrerequisiteProblems }: AddPrereqProps) {
  const id = parseIdFromUrl(url)

  if (id == null) {
    throw Error(`do not recognize url: ${url}`)
  }

  const problem = (await getProblem({ id })).data
  if (problem == null) {
    throw Error(`problem not found: ${url}`)
  }

  const problems = [...prerequisiteProblems, problem]
  setPrerequisiteProblems(problems)
}

export default function PrerequisiteProblemList({
  prerequisiteProblems, setPrerequisiteProblems,
}: Props) {
  const onChange = useCallback(
    (event: React.KeyboardEvent<HTMLInputElement>) => {
      if (event.key !== 'Enter') {
        return null
      }

      return addPrereq({
        url: event.currentTarget.value,
        setPrerequisiteProblems,
        prerequisiteProblems,
      })
    },
    [prerequisiteProblems, setPrerequisiteProblems],
  )

  return (
    <div className={styles.component}>
      {/* eslint-disable-next-line jsx-a11y/label-has-associated-control */}
      <label>Prerequisite problems</label>

      <ul>
        {
          prerequisiteProblems.map(({ description, id }) => (
            <Prereq
              description={description}
              id={id}
              key={id}
              prerequisiteProblems={prerequisiteProblems}
              setPrerequisiteProblems={setPrerequisiteProblems}
            />
          ))
        }
      </ul>

      <p>
        <label htmlFor="add-a-problem">
          Add a problem
          <br />
          <input
            id="add-a-problem"
            onKeyDown={onChange}
            placeholder="Problem url"
            size={100}
            type="url"
          />
        </label>
      </p>
    </div>
  )
}
