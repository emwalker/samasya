'use client'

import React, { useEffect, useState } from 'react'
import moment from 'moment'
import {
  Anchor, Box, Button, Card, Group,
} from '@mantine/core'
import queueService, { NextProblemResponse } from '@/services/queues'
import { handleError } from '@/app/handleResponse'
import { notifications } from '@mantine/notifications'
import TitleAndButton from '@/components/TitleAndButton'

type Props = {
  params: {
    id: string | null,
  } | null
}

export default function Page(props: Props) {
  const [response, setResponse] = useState<NextProblemResponse | null>(null)
  const queueId = props?.params?.id

  useEffect(() => {
    async function fetchData() {
      if (queueId == null) return
      const currResponse = await queueService.nextProblem(queueId)
      handleError(currResponse, 'Failed to get problem')
      setResponse(currResponse)
    }
    fetchData()
  }, [queueId, setResponse])

  const status = response?.data?.status

  if (status === 'emptyQueue') {
    notifications.show({
      title: 'Queue not ready',
      color: 'yellow',
      position: 'top-center',
      message: 'The queue is not ready',
    })
    return <main>Queue not ready</main>
  }

  if (response != null && status === 'notReady') {
    const fromNow = moment(response.data.availableAt).fromNow()
    return (
      <main>
        <Box pos="relative">
          No problems are ready to answer at this time.  The next problem will be
          available {fromNow}
        </Box>
      </main>
    )
  }

  const problem = response?.data?.problem
  const approach = response?.data?.approach

  return (
    <>
      <TitleAndButton title="Complete the next problem">
        <Button component="a" href={`/learning/queues/${queueId}`}>Done for now</Button>
      </TitleAndButton>

      {problem && (
        <Card padding="xl">
          <Box mb={20}>
            {problem.questionText}

            {problem.questionUrl && (
              <Box>
                Visit <Anchor target="_blank" href={problem.questionUrl}>this link</Anchor> and
                complete the problem.  Click on the button below that corresponds to the result of
                your first attempt this round.
              </Box>
            )}

            {approach && <Box>Use the &ldquo;{approach.name}&rdquo; approach</Box>}
          </Box>

          <Box mb={30}>How did you do?</Box>

          <Group justify="center">
            <Button size="xl" color="green">Correct</Button>
            <Button size="xl" color="yellow">Incorrect</Button>
            <Button size="xl" color="blue">Too hard</Button>
          </Group>
        </Card>
      )}
    </>
  )
}
