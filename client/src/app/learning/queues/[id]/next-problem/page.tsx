'use client'

import React, {
  useCallback, useEffect, useState,
} from 'react'
import moment from 'moment'
import Link from 'next/link'
import {
  Box, Button, Card, Group, LoadingOverlay, Title,
} from '@mantine/core'
import queueService, { OutcomeType, NextTaskResponse } from '@/services/queues'
import { placeholderOrganizationTrackId } from '@/constants'
import { handleError } from '@/app/handleResponse'
import { notifications } from '@mantine/notifications'
import TitleAndButton from '@/components/TitleAndButton'
import QuestionUrlPrompt from '@/components/QuestionUrlPrompt/page'
import classes from './page.module.css'

function useButtonHandler(
  addOutcome: (arg0: OutcomeType) => Promise<void>,
  outcome: OutcomeType,
) {
  return useCallback(async () => addOutcome(outcome), [addOutcome, outcome])
}

type Props = {
  params: {
    id: string | null,
  } | null
}

export default function Page(props: Props) {
  const [response, setResponse] = useState<NextTaskResponse | null>(null)
  const queueId = props?.params?.id
  const taskId = response?.data?.taskId
  const approachId = response?.data?.approachId

  useEffect(() => {
    async function fetchData() {
      if (queueId == null) return
      const currResponse = await queueService.nextTask(queueId)
      handleError(currResponse, 'Failed to get problem')
      setResponse(currResponse)
    }
    fetchData()
  }, [queueId, setResponse])

  const addOutcome = useCallback(async (outcome: OutcomeType) => {
    if (queueId == null || taskId == null || approachId == null) return

    const outcomeResponse = await queueService.addOutcome({
      queueId, approachId, organizationTrackId: placeholderOrganizationTrackId, outcome,
    })

    if (outcomeResponse.data?.message === 'ok') {
      notifications.show({
        title: 'Answer submitted',
        color: 'blue',
        message: 'Your answer has been successfully submitted',
        position: 'top-center',
      })
      // Refresh page
      queueService.nextTask(queueId).then(setResponse)
    } else {
      handleError(outcomeResponse, 'Problem submitting answer')
    }
  }, [queueId, taskId, approachId])

  const submitCorrect = useButtonHandler(addOutcome, 'completed')
  const submitIncorrect = useButtonHandler(addOutcome, 'needsRetry')
  const submitTooHard = useButtonHandler(addOutcome, 'tooHard')
  const status = response?.data?.status

  useEffect(() => {
    if (status === 'emptyQueue') {
      notifications.show({
        title: 'Queue not ready',
        color: 'yellow',
        position: 'top-center',
        message: 'The queue is not ready',
      })
    }
  }, [status])

  if (status === 'emptyQueue') {
    return <Box>This queue is not ready.</Box>
  }

  const queue = response?.data?.queue
  const problem = response?.data?.task
  const approach = response?.data?.approach

  if (response != null && status === 'notReady') {
    const fromNow = moment(response.data.availableAt).fromNow()
    const queueUrl = `/learning/queues/${queueId}`
    return (
      <Card padding="xl">
        <TitleAndButton title={queue?.summary || 'Loading page ...'}>
          <Button component="a" href={queueUrl}>Leave</Button>
        </TitleAndButton>

        <Box>
          No problems are ready to answer at this time.  The next problem will be
          available {fromNow}.  Follow <Link href={queueUrl}>this link</Link> to
          return to the queue page.
        </Box>
      </Card>
    )
  }

  return (
    <Box pos="relative" key={`${taskId}:${approachId}`}>
      <LoadingOverlay
        visible={response == null}
        zIndex={1000}
        overlayProps={{ radius: 'sm', blur: 2 }}
      />

      {queue && problem && (
        <Card padding="xl" className={classes.card} key={taskId}>
          <TitleAndButton title={queue?.summary || 'Loading page ...'}>
            <Button component="a" href={`/learning/queues/${queueId}`}>Leave</Button>
          </TitleAndButton>

          <Box my={30}>
            <Title order={5}>{problem.summary}</Title>
            {problem.questionText}
            {problem.questionUrl && <QuestionUrlPrompt questionUrl={problem.questionUrl} />}
            {approach && (
              approach.unspecified
                ? 'Any approach'
                : <Box>Use the following approach: {approach.summary}</Box>
            )}
          </Box>

          <Box mb={30}>How did you do?</Box>

          <Group justify="center">
            <Button size="xl" color="green" onClick={submitCorrect}>Correct</Button>
            <Button size="xl" color="yellow" onClick={submitIncorrect}>Incorrect</Button>
            <Button size="xl" color="orange" onClick={submitTooHard}>Too hard</Button>
          </Group>
        </Card>
      )}
    </Box>
  )
}
