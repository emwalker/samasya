'use client'

import React from 'react'
import Link from 'next/link'
import { getProblem } from '@/services/problems'

type Params = {
  params?: { id: string } | null
}

export default async function Page(params: Params) {
  if (params?.params == null) {
    return null
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
          Problem
        </h1>

        <p>
          { problem.description || 'No problem found' }
        </p>

        <p>
          <h3>Prerequisite skills</h3>
          <ul>
            {
              problem.prerequisiteSkills.map(({ description }) => (
                <li key={description}>{ description }</li>
              ))
            }
          </ul>
        </p>

        <p>
          <h3>Prerequisite problems</h3>
          <ul>
            {
              problem.prerequisiteProblems.map(({ description }) => (
                <li key={description}>{ description }</li>
              ))
            }
          </ul>
        </p>

        { problem && <Link href={`/problems/${problem.id}/edit`}>Edit</Link> }
      </div>
    </main>
  )
}
