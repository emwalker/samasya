import React, { useCallback } from 'react'
import { Approach } from '@/types'
import approachService from '@/services/approaches'
import styles from './styles.module.css'

type Props = {
  prereqApproaches: Approach[],
  setPrereqApproaches: (apporaches: Approach[]) => void,
}

type MakeRemoveOnClickProps = Props & {
  id: string
}

type PrereqProps = MakeRemoveOnClickProps & {
  description: string,
}

function Prereq({
  id, description, prereqApproaches, setPrereqApproaches,
}: PrereqProps) {
  const onClick = useCallback(
    () => {
      const index = prereqApproaches.findIndex(({ id: otherId }) => otherId === id)

      if (index > -1) {
        const approaches = [...prereqApproaches]
        approaches.splice(index, 1)
        setPrereqApproaches(approaches)
      }
    },
    [id, prereqApproaches, setPrereqApproaches],
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

async function addPrereq({ url, prereqApproaches, setPrereqApproaches }: AddPrereqProps) {
  const id = parseIdFromUrl(url)

  if (id == null) {
    throw Error(`do not recognize url: ${url}`)
  }

  const approach = (await approachService.get(id)).data
  if (approach == null) {
    throw Error(`approach not found: ${url}`)
  }

  const approaches = [...prereqApproaches, approach]
  setPrereqApproaches(approaches)
}

export default function PrerequisiteApproachList({ prereqApproaches, setPrereqApproaches }: Props) {
  const onChange = useCallback(
    (event: React.KeyboardEvent<HTMLInputElement>) => {
      if (event.key !== 'Enter') {
        return null
      }

      return addPrereq({
        url: event.currentTarget.value,
        setPrereqApproaches,
        prereqApproaches,
      })
    },
    [prereqApproaches, setPrereqApproaches],
  )

  return (
    <div className={styles.component}>
      {/* eslint-disable-next-line jsx-a11y/label-has-associated-control */}
      <label>Prerequisite approaches</label>

      <ul>
        {
          prereqApproaches.map(({ summary, id }) => (
            <Prereq
              description={summary}
              id={id}
              key={id}
              prereqApproaches={prereqApproaches}
              setPrereqApproaches={setPrereqApproaches}
            />
          ))
        }
      </ul>

      <p>
        <label htmlFor="add-an-approach">
          Add an approach
          <br />
          <input
            id="add-an-approach"
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
