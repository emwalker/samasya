'use client'

import React, { useEffect, useState } from 'react'
import queueService, { FetchResponse } from '@/services/queues'
import TitleAndButton from '@/components/TitleAndButton'
import {
  Button, Card, Box, LoadingOverlay,
} from '@mantine/core'
import ListOr from '@/components/ListOr'
import { AnswerEdge } from '@/types'

function Answer({ node }: AnswerEdge) {
  return (
    <Card key={node.id} mb={10}>
      {node.summary}
    </Card>
  )
}

type Props = {
  params: { id: string } | null
}

export default function Page(props: Props) {
  const [response, setResponse] = useState<FetchResponse | null>(null)
  const [isLoading, setIsLoading] = useState<boolean>(true)
  const queueId = props?.params?.id

  useEffect(() => {
    async function fetchData() {
      if (queueId == null) return
      const currResponse = await queueService.fetch(queueId)
      setResponse(currResponse)
      setIsLoading(false)
    }
    fetchData()
  }, [queueId])

  const data = response?.data

  return (
    <main>
      <Box pos="relative">
        <LoadingOverlay
          visible={isLoading}
          zIndex={1000}
          overlayProps={{ radius: 'sm', blur: 2 }}
        />

        {data && (
          <>
            <TitleAndButton title={data.queue.summary}>
              <Button
                component="a"
                href={`/learning/queues/${queueId}/next-problem`}
              >
                Continue
              </Button>
            </TitleAndButton>

            <Box mb={10}>This queue will help to work towards mastery of this problem:</Box>

            <Card shadow="lg">
              {data.targetProblem.summary}
            </Card>

            <ListOr title="Answers" fallback="No answers">
              {
                data.answers.edges.map(Answer)
              }
            </ListOr>
          </>
        )}
      </Box>
    </main>
  )
}
