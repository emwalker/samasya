import React from 'react'
import Link from 'next/link'
import queueService from '@/services/queues'
import constants from '@/constants'

export default async function Page() {
  const queues = (await queueService.getList(constants.placeholderUserId)).data

  return (
    <main>
      <h1 data-testid="page-name">Problem queues</h1>

      Open queues:
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
        <Link href="/learning/queues/new">Start another problem queue</Link>
      </p>
    </main>
  )
}
