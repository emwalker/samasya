import React from 'react'
import queueService from '@/services/queues'
import { notFound } from 'next/navigation'

type Props = {
  params: { id: string } | null
}

export default async function Page(props: Props) {
  const queueId = props?.params?.id
  if (queueId == null) {
    return <div>Loading ...</div>
  }

  const queue = (await queueService.get(queueId)).data
  if (queue == null) {
    return notFound()
  }

  return (
    <main>
      <h1>Problem queue</h1>

      <p>
        Problems working towards mastery of this problem:
        {' '}
        {queue.summary}
      </p>

      <div>
        <h2>Answers</h2>

        <ul>
          {
            queue.answerConnection.edges.map(
              (edge) => <li key={edge.node.id}>{edge.node.summary}</li>,
            )
          }
        </ul>
      </div>
    </main>
  )
}
