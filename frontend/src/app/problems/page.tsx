import React from 'react'
import Link from 'next/link'
import { Problem, GetProblemsResponse } from '@/types'

function Skills({ problem }: { problem: Problem }) {
  if (problem.prerequisiteSkills.length === 0) {
    return <span>(no skills)</span>
  }

  return (
    <>
      (
      <span>
        {problem.prerequisiteSkills.map(({ description }) => description).join(', ')}
      </span>
      )
    </>
  )
}

function ProblemComponent({ problem }: { problem: Problem }) {
  return (
    <>
      <Link href={`/problems/${problem.id}`}>
        {problem.description}
      </Link>
      {' '}
      <Skills problem={problem} />
    </>
  )
}

function Problems({ problems }: { problems: Problem[] }) {
  if (problems.length === 0) {
    return <div>No problems</div>
  }

  return (
    <ul>
      {
        problems.map((problem) => (
          <li key={problem.description}>
            <ProblemComponent problem={problem} />
          </li>
        ))
      }
    </ul>
  )
}

async function getData(): Promise<GetProblemsResponse> {
  const res = await fetch('http://localhost:8000/api/v1/problems', { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: [] })
  }

  return res.json()
}

export default async function Page() {
  const json = await getData()
  const problems = json.data || []

  return (
    <main>
      <h1 data-testid="page-name">Problems</h1>

      Available problems:

      <Problems problems={problems} />

      <p>
        <Link href="/problems/new">Add a problem</Link>
      </p>
    </main>
  )
}
