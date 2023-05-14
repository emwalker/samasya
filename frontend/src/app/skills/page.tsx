import React from 'react'
import Link from 'next/link'

type Skill = {
  description: string,
}

type Response = {
  data: Skill[],
}

async function getData(): Promise<Response> {
  const res = await fetch('http://localhost:8000/api/v1/skills', { cache: 'no-store' })

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
      <h1 data-testid="page-name">Skills</h1>

      Available skills:

      <ul>
        {
          skills.map((skill) => <li><div key={skill.description}>{skill.description}</div></li>)
        }
      </ul>

      <p>
        <Link href="/skills/new">Add a skill</Link>
      </p>
    </main>
  )
}
