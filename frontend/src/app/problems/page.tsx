import React from 'react'

type Problem = {
  description: string,
}

type Response = {
  data: Problem[],
}

async function getData(): Promise<Response> {
  const res = await fetch('http://localhost:8000/api/v1/problems', { cache: 'no-store' })

  if (!res.ok) {
    throw new Error('Failed to fetch data')
  }

  return res.json()
}

export default async function Page() {
  const json = await getData()
  const skills = json.data || []

  return (
    <main>
      <h1 data-testid="page-name">Problems</h1>

      Available problems:
      {
        skills.map((problem) => <div key={problem.description}>{ problem.description }</div>)
      }

      <p>
        <a href="/problems/new">Add a problem</a>
      </p>
    </main>
  )
}
