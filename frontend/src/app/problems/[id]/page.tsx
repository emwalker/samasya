'use client'

import React from 'react'
import Link from 'next/link'
import { Skill } from '../SkillDropdown'

type Problem = {
  id: string,
  description: string,
  skills: Skill[]
}

type Response = {
  data: Problem | null
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

export default async function Page(params: Params) {
  if (params?.params == null) {
    return null
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
          Problem
        </h1>

        <p>
          { problem.description || 'No problem found' }
        </p>

        <ul>
          {
            problem.skills.map(({ description }) => <li key={description}>{ description }</li>)
          }
        </ul>

        { problem && <Link href={`/problems/${problem.id}/edit`}>Edit</Link> }
      </div>
    </main>
  )
}
