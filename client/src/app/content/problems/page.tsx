import React from 'react'
import Link from 'next/link'
import { Button, Card } from '@mantine/core'
import { TaskType } from '@/types'
import TitleAndButton from '@/components/TitleAndButton'
import problemService from '@/services/problems'
import ListOr from '@/components/ListOr'
import classes from './page.module.css'

function ProblemCard({ id, summary }: TaskType) {
  return (
    <Card className={classes.card} key={id} mb={10}>
      <Link href={`/content/problems/${id}`}>
        {summary}
      </Link>
    </Card>
  )
}

export default async function Page() {
  const problems = (await problemService.list()).data

  return (
    <main>
      <TitleAndButton title="Problems">
        <Button component="a" href="/content/problems/new">New</Button>
      </TitleAndButton>

      <ListOr fallback="No problems">
        {problems.map(ProblemCard)}
      </ListOr>
    </main>
  )
}
