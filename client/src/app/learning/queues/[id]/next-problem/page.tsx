'use client'

import React, {
  useCallback, useEffect, useState,
} from 'react'
import moment from 'moment'
import {
  Anchor, Box, Button, Card, Group,
  LoadingOverlay,
  Title,
} from '@mantine/core'
import queueService, { AnswerState, NextProblemResponse } from '@/services/queues'
import { handleError } from '@/app/handleResponse'
import { notifications } from '@mantine/notifications'
import TitleAndButton from '@/components/TitleAndButton'

function useButtonHandler(
  updateAnswer: (arg0: AnswerState) => Promise<void>,
  answerState: AnswerState,
) {
  const callback = useCallback(async () => {
    updateAnswer(answerState)
  }, [updateAnswer, answerState])
  return callback
}

type Props = {
  params: {
    id: string | null,
  } | null
}

export default function Page(props: Props) {
  const [response, setResponse] = useState<NextProblemResponse | null>(null)
  const queueId = props?.params?.id
  const problemId = response?.data?.problemId
  const approachId = response?.data?.approachId

  useEffect(() => {
    async function fetchData() {
      if (queueId == null) return
      const currResponse = await queueService.nextProblem(queueId)
      handleError(currResponse, 'Failed to get problem')
      setResponse(currResponse)
    }
    fetchData()
  }, [queueId, setResponse])

  const updateAnswer = useCallback(async (answerState: AnswerState) => {
    if (queueId == null || problemId == null) return

    const answerResponse = await queueService.addAnswer({
      queueId, problemId, approachId: approachId || null, answerState,
    })

    if (answerResponse.data?.message === 'ok') {
      notifications.show({
        title: 'Answer submitted',
        color: 'blue',
        message: 'Your answer has been successfully submitted',
        position: 'top-center',
      })
      // Refresh page
      queueService.nextProblem(queueId).then(setResponse)
    } else {
      handleError(answerResponse, 'Problem submitting answer')
    }
  }, [queueId, problemId, approachId])

  const submitCorrect = useButtonHandler(updateAnswer, 'correct')
  const submitIncorrect = useButtonHandler(updateAnswer, 'incorrect')
  const submitTooHard = useButtonHandler(updateAnswer, 'unsure')

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

  if (response != null && status === 'notReady') {
    const fromNow = moment(response.data.availableAt).fromNow()
    return (
      <Box>
        No problems are ready to answer at this time.  The next problem will be
        available {fromNow}
      </Box>
    )
  }

  const queue = response?.data?.queue
  const problem = response?.data?.problem
  const approach = response?.data?.approach

  return (
    <Box pos="relative">
      <LoadingOverlay
        visible={response == null}
        zIndex={1000}
        overlayProps={{ radius: 'sm', blur: 2 }}
      />

      {queue && problem && (
        <Card padding="xl">
          <TitleAndButton title={queue?.summary || 'Loading page ...'}>
            <Button component="a" href={`/learning/queues/${queueId}`}>Leave</Button>
          </TitleAndButton>

          <Box my={30}>
            <Title order={5}>{problem.summary}</Title>
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
            <Button size="xl" color="green" onClick={submitCorrect}>Correct</Button>
            <Button size="xl" color="yellow" onClick={submitIncorrect}>Incorrect</Button>
            <Button size="xl" color="orange" onClick={submitTooHard}>Too hard</Button>
          </Group>
        </Card>
      )}
    </Box>
  )
}
