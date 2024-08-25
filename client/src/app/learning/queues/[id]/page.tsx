import React from 'react'
import queueService from '@/services/queues'
import { notFound } from 'next/navigation'
import TitleAndButton from '@/components/TitleAndButton'
import { Button, Card, Box } from '@mantine/core'

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
      <TitleAndButton title={queue.summary}>
        <Button component="a" href={`/learning/queues/${queue.id}/next-problem`}>Resume</Button>
      </TitleAndButton>

      <Box mb={10}>This queue will help to work towards mastery of this problem:</Box>

      <Card shadow="lg">
        Problem goes here
      </Card>

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
