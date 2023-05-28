import React from 'react'
import Link from 'next/link'
import { getSkills } from '@/services/skills'

export default async function Page() {
  const skills = (await getSkills()).data

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
