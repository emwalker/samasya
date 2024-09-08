'use client'

import React, {
  ChangeEvent,
  useCallback,
  useEffect,
  useState,
} from 'react'
import TitleAndButton from '@/components/TitleAndButton'
import {
  Box,
  Button,
  Group,
  Select,
  TextInput,
} from '@mantine/core'
import Link from 'next/link'
import queueService, { FetchData } from '@/services/queues'
import { handleError } from '@/app/handleResponse'
import { Cadence, QueueStrategy } from '@/types'
import { useRouter } from 'next/navigation'
import { notifications } from '@mantine/notifications'

const cadenceOptions = [
  { label: 'Minutes', value: 'minutes' },
  { label: 'Hours', value: 'hours' },
  { label: 'Days', value: 'days' },
]

const strategyOptions = [
  { label: 'Deterministic', value: 'deterministic' },
  { label: 'Spaced repetition', value: 'spacedRepetitionV1' },
]

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

  useEffect(() => {
    async function loadData() {
      if (queueId == null) return
      const response = await queueService.fetch(queueId)
      handleError(response, 'Failed to fetch queue information')
      const currFetchData = response?.data || null
      setFetchData(currFetchData)
      setSummary(currFetchData?.queue?.summary || null)
      setCadence(currFetchData?.queue?.cadence || null)
      setStrategy(currFetchData?.queue?.strategy || null)
    }
    loadData()
  }, [queueId, setFetchData, setSummary, setCadence, setStrategy])

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

  return (
    <Box key={queueId}>
      {queue && (
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
        </>
      )}
    </Box>
  )
}
