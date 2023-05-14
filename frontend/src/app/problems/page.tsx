import React from 'react'
import Link from 'next/link'

type SkillType = {
  id: string,
  description: string,
}

type ProblemType = {
  id: string,
  description: string,
  skills: SkillType[],
}

type Response = {
  data: ProblemType[],
}

function Skills({ problem }: { problem: ProblemType }) {
  if (problem.skills.length === 0) {
    return <span>(no skills)</span>
  }

  return (
    <>
      (
      <span>
        {problem.skills.map(({ description }) => description).join(', ')}
      </span>
      )
    </>
  )
}

function Problem({ problem }: { problem: ProblemType }) {
  return (
    <Link href={`/problems/${problem.id}`}>
      {problem.description}
      {' '}
      <Skills problem={problem} />
    </Link>
  )
}

function Problems({ problems }: { problems: ProblemType[] }) {
  if (problems.length === 0) {
    return <div>No problems</div>
  }

  return (
    <ul>
      {
        problems.map((problem) => <li key={problem.description}><Problem problem={problem} /></li>)
      }
    </ul>
  )
}

async function getData(): Promise<Response> {
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
