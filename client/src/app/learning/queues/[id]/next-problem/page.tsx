'use client'

import React, {
  useCallback, useEffect, useState,
} from 'react'
import moment from 'moment'
import {
  Anchor, Box, Button, Card, Group,
} from '@mantine/core'
// import { useRouter } from 'next/navigation'
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
  // const router = useRouter()
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
      // router.push(`/learning/queues/${queueId}/next-problem`)
    } else {
      handleError(answerResponse, 'Problem submitting answer')
    }
  }, [queueId, problemId, approachId])

  const submitCorrect = useButtonHandler(updateAnswer, 'correct')
  const submitIncorrect = useButtonHandler(updateAnswer, 'incorrect')
  const submitTooHard = useButtonHandler(updateAnswer, 'tooHard')

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
            <Button size="xl" color="green" onClick={submitCorrect}>Correct</Button>
            <Button size="xl" color="yellow" onClick={submitIncorrect}>Incorrect</Button>
            <Button size="xl" color="orange" onClick={submitTooHard}>Too hard</Button>
          </Group>
        </Card>
      )}
    </>
  )
}
