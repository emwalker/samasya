import React from 'react'
import skillService from '@/services/skills'
import { Button } from '@mantine/core'
import Link from 'next/link'

export default async function Page() {
  const skills = (await skillService.getList()).data

  return (
    <main>
      <h1 data-testid="page-name">Skills, milestones and attainments</h1>

      <ul>
        {
          skills.map(({ id, summary }) => (
            <li key={id}>
              <Link href={`/content/skills/${id}`}>{summary}</Link>
            </li>
          ))
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
