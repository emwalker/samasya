import React from 'react'
import skillService from '@/services/skills'
import { Button } from '@mantine/core'
import Link from 'next/link'
import TitleAndButton from '@/components/TitleAndButton'

export default async function Page() {
  const skills = (await skillService.getList()).data

  return (
    <main>
      <TitleAndButton title="Skills and milestones">
        <Button
          component="a"
          href="/content/skills/new"
        >
          New
        </Button>
      </TitleAndButton>

      <ul>
        {
          skills.map(({ id, summary }) => (
            <li key={id}>
              <Link href={`/content/skills/${id}`}>{summary}</Link>
            </li>
          ))
        }
      </ul>
    </main>
  )
}
