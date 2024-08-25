import React from 'react'
import skillService from '@/services/skills'
import { Button } from '@mantine/core'

export default async function Page() {
  const skills = (await skillService.getList()).data

  return (
    <main>
      <h1 data-testid="page-name">Skills</h1>

      <ul>
        {
          skills.map((skill) => <li key={skill.id}><div>{skill.summary}</div></li>)
        }
      </ul>

      <Button
        component="a"
        href="/content/skills/new"
      >
        Add a skill
      </Button>
    </main>
  )
}
