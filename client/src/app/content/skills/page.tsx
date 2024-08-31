'use client'

import React, { useEffect, useState } from 'react'
import skillService, { ListResponse } from '@/services/skills'
import { Button } from '@mantine/core'
import Link from 'next/link'
import TitleAndButton from '@/components/TitleAndButton'
import { SkillType } from '@/types'

function SkillCard({ id, summary }: SkillType) {
  return (
    <li key={id}>
      <Link href={`/content/skills/${id}`}>{summary}</Link>
    </li>
  )
}

export default function Page() {
  const [response, setResponse] = useState<ListResponse | null>(null)

  useEffect(() => {
    async function fetchData() {
      const currResponse = await skillService.list()
      setResponse(currResponse)
    }
    fetchData()
  }, [setResponse])

  const skills = response?.data || []

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
        {skills.map(SkillCard)}
      </ul>
    </main>
  )
}
