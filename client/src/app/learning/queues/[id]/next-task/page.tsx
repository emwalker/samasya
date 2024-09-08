'use client'

import React, {
  useCallback, useEffect, useState,
} from 'react'
import moment from 'moment'
import Link from 'next/link'
import {
  Box,
  Button,
  Card,
  Group,
  LoadingOverlay,
  Select,
  Title,
} from '@mantine/core'
import queueService, { OutcomeType, NextTaskResponse } from '@/services/queues'
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
  const [trackId, setTrackId] = useState<string | null>(null)
  const queueId = props?.params?.id
  const taskId = response?.data?.taskId
  const approachId = response?.data?.approachId

  useEffect(() => {
    async function fetchData() {
      if (queueId == null) return
      const currResponse = await queueService.nextTask(queueId)
      const initialTrackId = (currResponse?.data?.availableTracks || [])[0]?.trackId || null
      handleError(currResponse, 'Failed to get problem')
      setResponse(currResponse)
      setTrackId(initialTrackId)
    }
    fetchData()
  }, [queueId, setResponse])

  const addOutcome = useCallback(async (outcome: OutcomeType) => {
    if (queueId == null || taskId == null || approachId == null || trackId == null) return

    const outcomeResponse = await queueService.addOutcome({
      queueId,
      approachId,
      repoTrackId: trackId,
      outcome,
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
  }, [queueId, taskId, approachId, trackId])

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

  const fetchData = response?.data || null
  const queue = fetchData?.queue
  const task = fetchData?.task
  const approach = fetchData?.approach
  const availableTracks = fetchData?.availableTracks
    ?.map(({ trackId: currTrackId, trackName }) => ({ value: currTrackId, label: trackName })) || []

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

  const disabled = trackId == null

  return (
    <Box pos="relative" key={`${taskId}:${approachId}`}>
      <LoadingOverlay
        visible={response == null}
        zIndex={1000}
        overlayProps={{ radius: 'sm', blur: 2 }}
      />

      {queue && task && (
        <Card padding="xl" className={classes.card} key={taskId}>
          <TitleAndButton title={queue?.summary || 'Loading page ...'}>
            <Button component="a" href={`/learning/queues/${queueId}`}>Leave</Button>
          </TitleAndButton>

          <Box my={20}>
            <Title order={5}>{task.summary}</Title>
            {task.questionText}
            {task.questionUrl && <QuestionUrlPrompt questionUrl={task.questionUrl} />}
            {approach && (
              approach.unspecified
                ? 'Any approach'
                : <Box>Use the following approach: {approach.summary}</Box>
            )}
          </Box>

          <Select
            data={availableTracks}
            defaultValue={trackId}
            label="Track"
            mb={40}
            onChange={setTrackId}
            placeholder="Select a track"
          />

          <Box mb={30}>How did you do?</Box>

          <Group justify="center">
            <Button
              color="green"
              disabled={disabled}
              onClick={submitCorrect}
              size="xl"
            >
              Correct
            </Button>
            <Button
              color="yellow"
              disabled={disabled}
              onClick={submitIncorrect}
              size="xl"
            >
              Incorrect
            </Button>
            <Button
              color="orange"
              disabled={disabled}
              onClick={submitTooHard}
              size="xl"
            >
              Too hard
            </Button>
          </Group>
        </Card>
      )}
    </Box>
  )
}
