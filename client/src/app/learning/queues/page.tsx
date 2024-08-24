import React from 'react'
import Link from 'next/link'
import queueService from '@/services/queues'
import constants from '@/constants'
import { Button } from '@mantine/core'

export default async function Page() {
  const queues = (await queueService.getList(constants.placeholderUserId)).data

  return (
    <main>
      <h1 data-testid="page-name">Problem queues</h1>

      <ul>
        {
          queues.map((queue) => (
            <li key={queue.id}>
              <Link href={`/learning/queues/${queue.id}`}>{queue.summary}</Link>
            </li>
          ))
        }
      </ul>

      <p>
        <Button
          component="a"
          href="/learning/queues/new"
        >
          Start a new queue
        </Button>
      </p>
    </main>
  )
}
