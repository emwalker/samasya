'use client'

import React from 'react'
import Link from 'next/link'
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
          <li key={skill.id}>{skill.summary}</li>
        ))}
      </ListOr>

      <ListOr title="Prerequisite approaches" fallback="No required approaches">
        {approach.prereqApproaches.map(({ id, summary, name }) => (
          <li key={id}>
            {summary}
            {' '}
            (
            {name}
            )
          </li>
        ))}
      </ListOr>

      <Link href={`/content/approaches/${approach.id}/edit`}>Edit</Link>
    </div>
  )
}

type Params = {
  params?: { id: string } | null
}

// eslint-disable-next-line @next/next/no-async-client-component
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
              <li><ApproachItem approach={approach} /></li>
            ))
          }
        </ListOr>

        <Link href={`/content/problems/${id}/approaches/new`}>Add an approach</Link>
        <br />
        <Link href={`/content/problems/${id}/edit`}>Edit problem</Link>
      </div>
    </main>
  )
}
