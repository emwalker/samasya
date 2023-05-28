import React from 'react'
import Link from 'next/link'
import { Problem } from '@/types'
import { getProblems } from '@/services/problems'

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

export default async function Page() {
  const problems = (await getProblems()).data

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
