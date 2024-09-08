'use client'

import React, { useCallback, useEffect, useState } from 'react'
import queueService, {
  FetchData,
  OutcomeType,
  QueueOutcomeType,
  TrackRowType,
} from '@/services/queues'
import TitleAndButton from '@/components/TitleAndButton'
import {
  Badge,
  Box,
  Button,
  Card,
  Center,
  Group,
  LoadingOverlay,
  Table,
  Title,
} from '@mantine/core'
import moment from 'moment'
import { actionText, outcomeText } from '@/helpers'
import { ApiResponse } from '@/types'
import Queue from '@/components/Queue'
import { IconX } from '@tabler/icons-react'
import { handleError } from '@/app/handleResponse'
import classes from './page.module.css'

function progressColor(correct: number) {
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

const badgeColors: Record<OutcomeType, string> = {
  completed: 'green',
  needsRetry: 'yellow',
  tooHard: 'orange',
}

type TrackRowProps = {
  track: TrackRowType,
  removeTrack: (trackId: string) => Promise<void>
}

function TrackRow({ track, removeTrack }: TrackRowProps) {
  const {
    queueId,
    categoryName,
    trackName,
    trackId,
  } = track

  return (
    <Table.Tr key={`${queueId}:${trackId}`}>
      <Table.Td>{categoryName}</Table.Td>
      <Table.Td><Badge color="blue.3">{trackName}</Badge></Table.Td>
      <Table.Td align="right">
        <IconX
          color="var(--mantine-color-dark-1)"
          className={classes.removeButton}
          onClick={() => removeTrack(trackId)}
        />
      </Table.Td>
    </Table.Tr>
  )
}

function OutcomeRow({
  taskAvailableAt,
  outcome,
}: QueueOutcomeType) {
  const statusColor = badgeColors[outcome.outcome] || 'red'
  const correctColor = progressColor(outcome.progress)
  const addedAt = moment(outcome.addedAt).fromNow()
  const availableAt = moment(taskAvailableAt).fromNow()
  const outcomeLabel = outcomeText(outcome.outcome)

  return (
    <Table.Tr key={outcome.id}>
      <Table.Td>{outcome.taskSummary}</Table.Td>
      <Table.Td align="center"><Badge color="blue.3">{outcome.trackName}</Badge></Table.Td>
      <Table.Td>{outcome.approachSummary}</Table.Td>
      <Table.Td>{addedAt}</Table.Td>
      <Table.Td>{availableAt}</Table.Td>
      <Table.Td align="center"><Badge color={statusColor}>{outcomeLabel}</Badge></Table.Td>
      <Table.Td align="center"><Badge color={correctColor}>{outcome.progress}</Badge></Table.Td>
    </Table.Tr>
  )
}

type Props = {
  params: { id: string } | null
}

export default function Page(props: Props) {
  const [response, setResponse] = useState<ApiResponse<FetchData> | null>(null)
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

  const refreshParent = useCallback(() => {
    if (queueId == null) return
    queueService.fetch(queueId).then(setResponse)
  }, [queueId])

  const removeTrack = useCallback(async (trackId: string) => {
    if (queueId == null) return
    const currResponse = await queueService.removeTrack(queueId, { queueId, trackId })
    handleError(currResponse, 'Failed to remove track')
    refreshParent()
  }, [queueId, refreshParent])

  const data = response?.data

  return (
    <Box pos="relative" key={queueId}>
      <LoadingOverlay
        visible={isLoading}
        zIndex={1000}
        overlayProps={{ radius: 'sm', blur: 2 }}
      />

      {data && queueId && (
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
                href={`/learning/queues/${queueId}/next-task`}
              >
                Continue
              </Button>
            </Group>
          </TitleAndButton>

          <Box mt={20}>
            <Group>
              <Badge color="blue.3">{actionText(data.targetTask.action)}</Badge>
              <Badge color="blue.2">{data.queue.cadence}</Badge>
              <Badge color="blue.5">{data.queue.strategy}</Badge>
            </Group>
          </Box>

          <Card shadow="lg" mt={20}>
            {data.targetTask.summary}
          </Card>

          <Box mt={50}>
            <Title mb={10} order={3}>Selected tracks</Title>

            <Queue.CategoryTrackSelect queueId={queueId} refreshParent={refreshParent} />

            <Table>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>Category</Table.Th>
                  <Table.Th>Track</Table.Th>
                  <Table.Th />
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {data.tracks.map((track) => (
                  <TrackRow
                    key={track.trackId}
                    track={track}
                    removeTrack={removeTrack}
                  />
                ))}
              </Table.Tbody>
            </Table>
          </Box>

          <Box mt={50}>
            <Title order={3}>Progress through queue</Title>
            <Table mt={10}>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>Task</Table.Th>
                  <Table.Th><Center>Track</Center></Table.Th>
                  <Table.Th>Approach</Table.Th>
                  <Table.Th>Completed</Table.Th>
                  <Table.Th>Will be seen again</Table.Th>
                  <Table.Th><Center>Outcome</Center></Table.Th>
                  <Table.Th><Center>Progress</Center></Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {data.outcomes.map(OutcomeRow)}
              </Table.Tbody>
            </Table>
          </Box>
        </>
      )}
    </Box>
  )
}
