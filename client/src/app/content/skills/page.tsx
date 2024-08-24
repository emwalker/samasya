import React from 'react'
import Link from 'next/link'
import skillService from '@/services/skills'

export default async function Page() {
  const skills = (await skillService.getList()).data

  return (
    <main>
      <h1 data-testid="page-name">Skills</h1>

      Available skills:

      <ul>
        {
          skills.map((skill) => <li key={skill.id}><div>{skill.summary}</div></li>)
        }
      </ul>

      <p>
        <Link href="/content/skills/new">Add a skill</Link>
      </p>
    </main>
  )
}
