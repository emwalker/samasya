import React from 'react'
import Link from 'next/link'
import queueService from '@/services/queues'
import { placeholderUserId as userId } from '@/constants'

export default async function Page() {
  const queues = (await queueService.getList(userId)).data

  return (
    <main>
      <h1 data-testid="page-name">Problem queues</h1>

      Open queues:

      <ul>
        {
          queues.map((queue) => <li key={queue.id}><div>{queue.summary}</div></li>)
        }
      </ul>

      <p>
        <Link href="/learning/queues/new">Start a queue</Link>
      </p>
    </main>
  )
}
