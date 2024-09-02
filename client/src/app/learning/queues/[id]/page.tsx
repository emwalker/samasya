'use client'

import React, { useEffect, useState } from 'react'
import queueService, { AnswerState, FetchResponse, QueueAnswerType } from '@/services/queues'
import TitleAndButton from '@/components/TitleAndButton'
import {
  Button, Card, Box, LoadingOverlay, Table, Badge, Center,
  Group,
} from '@mantine/core'
import moment from 'moment'

function colorForConsecutiveCorrect(correct: number) {
  if (correct < 2) return 'orange'
  if (correct < 6) return 'yellow'
  if (correct < 7) return 'green'
  if (correct < 8) return 'lime.8'
  if (correct < 9) return 'lime.7'
  if (correct < 10) return 'lime.6'
  if (correct < 11) return 'lime.5'
  if (correct < 12) return 'lime.4'
  if (correct < 13) return 'lime.3'
  if (correct < 14) return 'lime.2'
  return 'lime.1'
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
  answerAvailableAt,
  answerState,
  answerConsecutiveCorrect: correct,
}: QueueAnswerType) {
  const statusColor = badgeColors[answerState] || 'red'
  const correctColor = colorForConsecutiveCorrect(correct)
  const answeredAt = moment(answerAnsweredAt).fromNow()
  const availableAt = moment(answerAvailableAt).fromNow()

  return (
    <Table.Tr key={answerId}>
      <Table.Td>{problemSummary}</Table.Td>
      <Table.Td>{answeredAt}</Table.Td>
      <Table.Td>{availableAt}</Table.Td>
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
    <Box pos="relative">
      <LoadingOverlay
        visible={isLoading}
        zIndex={1000}
        overlayProps={{ radius: 'sm', blur: 2 }}
      />

      {data && (
        <>
          <TitleAndButton title={data.queue.summary}>
            <Group>
              <Button
                component="a"
                variant="outline"
                href={`/learning/queues/${queueId}/edit`}
              >
                Edit
              </Button>
              <Button
                component="a"
                href={`/learning/queues/${queueId}/next-problem`}
              >
                Continue
              </Button>
            </Group>
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
                <Table.Th>Will be seen again</Table.Th>
                <Table.Th><Center>Result</Center></Table.Th>
                <Table.Th><Center>Progress</Center></Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {data.answers.map(AnswerRow)}
            </Table.Tbody>
          </Table>
        </>
      )}
    </Box>
  )
}
