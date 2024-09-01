'use client'

import React, { useEffect, useState } from 'react'
import queueService, { AnswerState, FetchResponse, QueueAnswerType } from '@/services/queues'
import TitleAndButton from '@/components/TitleAndButton'
import {
  Button, Card, Box, LoadingOverlay,
  Table,
  Badge,
  Center,
} from '@mantine/core'
import moment from 'moment'

function colorForConsecutiveCorrect(correct: number) {
  if (correct < 2) return 'orange'
  if (correct < 6) return 'yellow'
  if (correct < 10) return 'green'
  return 'lime.4'
}

const badgeColors: Record<AnswerState, string> = {
  correct: 'green',
  incorrect: 'yellow',
  unsure: 'orange',
}

function AnswerRow({
  problemSummary,
  answerId,
  answerAnsweredAt,
  answerState,
  answerConsecutiveCorrect: correct,
}: QueueAnswerType) {
  const statusColor = badgeColors[answerState] || 'red'
  const correctColor = colorForConsecutiveCorrect(correct)
  const fromNow = moment(answerAnsweredAt).fromNow()

  return (
    <Table.Tr key={answerId}>
      <Table.Td>{problemSummary}</Table.Td>
      <Table.Td>{fromNow}</Table.Td>
      <Table.Td align="center"><Badge color={statusColor}>{answerState}</Badge></Table.Td>
      <Table.Td align="center"><Badge color={correctColor}>{correct}</Badge></Table.Td>
    </Table.Tr>
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

            <Card shadow="lg" mb={30}>
              {data.targetProblem.summary}
            </Card>

            <Table>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>Problem</Table.Th>
                  <Table.Th>Answered</Table.Th>
                  <Table.Th><Center>Result</Center></Table.Th>
                  <Table.Th><Center>Answered correctly</Center></Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {data.answers.map(AnswerRow)}
              </Table.Tbody>
            </Table>
          </>
        )}
      </Box>
    </main>
  )
}
