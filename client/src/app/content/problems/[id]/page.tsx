import React from 'react'
import { Button } from '@mantine/core'
import problemService from '@/services/problems'
import { WideApproach } from '@/types'
import ListOr from '@/components/ListOr'
import styles from './styles.module.css'

function ApproachItem({ approach }: { approach: WideApproach }) {
  return (
    <div className={styles.approach}>
      <div>
        Name:
        {' '}
        {approach.name}
      </div>

      <ListOr title="Prerequisite skills" fallback="No required skills">
        {approach.prereqSkills.map((skill) => (
          <div key={skill.id}>{skill.summary}</div>
        ))}
      </ListOr>

      <ListOr title="Prerequisite approaches" fallback="No required approaches">
        {approach.prereqApproaches.map(({ id, summary, name }) => (
          <div key={id}>
            {summary}
            {' '}
            (
            {name}
            )
          </div>
        ))}
      </ListOr>

      <Button
        component="a"
        href={`/content/approaches/${approach.id}/edit`}
      >
        Modify
      </Button>
    </div>
  )
}

type Params = {
  params?: { id: string } | null
}

export default async function Page(params: Params) {
  if (params?.params == null) {
    return null
  }

  const { params: { id } } = params
  const problem = (await problemService.get(id)).data
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
          Problem
        </h1>

        <p>
          {problem.summary}
        </p>

        <p>
          {problem.questionUrl}
        </p>

        <p>
          {problem.questionText}
        </p>

        <ListOr title="Approaches" fallback="No approaches">
          {
            problem.approaches.map((approach) => (
              <div><ApproachItem approach={approach} /></div>
            ))
          }
        </ListOr>

        <Button
          component="a"
          mr={3}
          href={`/content/problems/${id}/approaches/new`}
        >
          Add an approach
        </Button>

        <Button
          component="a"
          mr={3}
          href={`/content/problems/${id}/edit`}
        >
          Update
        </Button>
      </div>
    </main>
  )
}
