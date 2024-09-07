import React from 'react'
import Link from 'next/link'
import queueService from '@/services/queues'
import { placeholderUserId } from '@/constants'
import { Button, Card } from '@mantine/core'
import TitleAndButton from '@/components/TitleAndButton'
import { QueueType } from '@/types'
import classes from './page.module.css'

function Queue({ id, summary }: QueueType) {
  return (
    <Card key={id} className={classes.card}>
      <Link href={`/learning/queues/${id}`}>{summary}</Link>
    </Card>
  )
}

export default async function Page() {
  const queues = (await queueService.list(placeholderUserId)).data

  return (
    <main>
      <TitleAndButton title="Queues">
        <Button
          component="a"
          href="/learning/queues/new"
        >
          New
        </Button>
      </TitleAndButton>

      {queues.map(Queue)}
    </main>
  )
}
