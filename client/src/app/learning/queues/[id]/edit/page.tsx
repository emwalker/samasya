'use client'

import React, {
  ChangeEvent,
  useCallback,
  useEffect,
  useState,
} from 'react'
import TitleAndButton from '@/components/TitleAndButton'
import {
  Badge,
  Box,
  Button,
  Group,
  Select,
  Table,
  TextInput,
  Title,
} from '@mantine/core'
import Link from 'next/link'
import queueService, { FetchData, TrackRowType } from '@/services/queues'
import { handleError } from '@/app/handleResponse'
import { ApiResponse, Cadence, QueueStrategy } from '@/types'
import { useRouter } from 'next/navigation'
import { notifications } from '@mantine/notifications'
import Queue from '@/components/Queue'
import { IconX } from '@tabler/icons-react'
import classes from './page.module.css'

const cadenceOptions = [
  { label: 'Minutes', value: 'minutes' },
  { label: 'Hours', value: 'hours' },
  { label: 'Days', value: 'days' },
]

const strategyOptions = [
  { label: 'Deterministic', value: 'deterministic' },
  { label: 'Spaced repetition', value: 'spacedRepetitionV1' },
]

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

type Props = {
  params: { id: string } | null
}

export default function Page(props: Props) {
  const router = useRouter()
  const [fetchData, setFetchData] = useState<FetchData | null>(null)
  const [summary, setSummary] = useState<string | null>(null)
  const [strategy, setStrategy] = useState<QueueStrategy | null>(null)
  const [cadence, setCadence] = useState<Cadence | null>(null)
  const queueId = props?.params?.id || null
  const queue = fetchData?.queue || null

  const setResponse = useCallback(async (response: ApiResponse<FetchData>) => {
    handleError(response, 'Failed to fetch queue information')
    const currFetchData = response?.data || null
    setFetchData(currFetchData)
    setSummary(currFetchData?.queue?.summary || null)
    setCadence(currFetchData?.queue?.cadence || null)
    setStrategy(currFetchData?.queue?.strategy || null)
  }, [setFetchData, setSummary, setCadence, setStrategy])

  useEffect(() => {
    async function loadData() {
      if (queueId == null) return
      const response = await queueService.fetch(queueId)
      setResponse(response)
    }
    loadData()
  }, [queueId, setResponse])

  const summaryOnChange = useCallback((event: ChangeEvent<HTMLInputElement>) => {
    setSummary(event.target.value)
  }, [setSummary])

  const cadenceOnChange = useCallback((value: string | null) => {
    setCadence(value as Cadence)
  }, [setCadence])

  const strategyOnChange = useCallback((value: string | null) => {
    setStrategy(value as QueueStrategy)
  }, [setStrategy])

  const updateQueue = useCallback(async () => {
    if (queueId == null || summary == null || strategy == null || cadence == null) return

    const payload = {
      queueId,
      summary,
      strategy,
      cadence,
    }
    const response = await queueService.update(queueId, payload)

    if (response.data == null) {
      handleError(response, 'Failed to update queue')
    } else {
      notifications.show({
        color: 'blue',
        title: 'Queue saved',
        position: 'top-center',
        message: 'This queue has been updated',
      })
      router.push(`/learning/queues/${queueId}`)
    }
  }, [queueId, summary, strategy, cadence, router])

  const refreshParent = useCallback(() => {
    if (queueId == null) return
    queueService.fetch(queueId).then(setResponse)
  }, [queueId, setResponse])

  const removeTrack = useCallback(async (trackId: string) => {
    if (queueId == null) return
    const currResponse = await queueService.removeTrack(queueId, { queueId, trackId })
    handleError(currResponse, 'Failed to remove track')
    refreshParent()
  }, [queueId, refreshParent])

  return (
    <Box key={queueId}>
      {fetchData && queueId && queue && (
        <>
          <TitleAndButton title={queue.summary}>
            <Group>
              <Button onClick={updateQueue}>Save</Button>
              {' or '}
              <Link href={`/learning/queues/${queueId}`}>cancel</Link>
            </Group>
          </TitleAndButton>

          <TextInput
            defaultValue={summary || ''}
            label="Summary"
            onChange={summaryOnChange}
            placeholder="Short summary that can be shown in lists"
          />

          <Select
            data={cadenceOptions}
            defaultValue={cadence}
            label="How often the queue shows new tasks"
            onChange={cadenceOnChange}
            mt={20}
          />

          <Select
            data={strategyOptions}
            defaultValue={strategy}
            label="Algorithm for choosing new tasks"
            onChange={strategyOnChange}
            mt={20}
          />

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
                {fetchData.tracks.map((track) => (
                  <TrackRow
                    key={track.trackId}
                    track={track}
                    removeTrack={removeTrack}
                  />
                ))}
              </Table.Tbody>
            </Table>
          </Box>
        </>
      )}
    </Box>
  )
}
