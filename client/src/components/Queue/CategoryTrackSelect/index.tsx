'use client'

import React, { useCallback, useState } from 'react'
import { ApiResponse } from '@/types'
import { Box, Button, Select } from '@mantine/core'
import queueService, { AvailableTrackData } from '@/services/queues'
import { handleError } from '@/app/handleResponse'

type Props = {
  queueId: string,
  refreshParent: () => void,
}

export default function CategoryTrackSelect({ queueId, refreshParent }: Props) {
  const [response, setResponse] = useState<ApiResponse<AvailableTrackData[]> | null>(null)
  const [categoryId, setCategoryId] = useState<string | null>(null)
  const [trackId, setTrackId] = useState<string | null>(null)

  const trackOnSearchChange = useCallback(async (searchString: string) => {
    const currResponse = await queueService.availableTracks(queueId, searchString)
    handleError(currResponse, 'Failed to get available tracks')
    setResponse(currResponse)
  }, [setResponse, queueId])

  const addTrack = useCallback(async () => {
    if (trackId == null || categoryId == null) return
    const currResponse = await queueService.addTrack(queueId, { queueId, trackId, categoryId })
    handleError(currResponse, 'Failed to add track')
    refreshParent()
  }, [trackId, refreshParent, categoryId, queueId])

  const selectTrack = useCallback(async (compoundKey: string | null) => {
    if (compoundKey == null) {
      setCategoryId(null)
      setTrackId(null)
      return
    }

    const [currCategoryId, currTrackId] = compoundKey.split(':')
    setCategoryId(currCategoryId)
    setTrackId(currTrackId)
  }, [setTrackId, setCategoryId])

  const options = response?.data?.map(({
    categoryId: currCategoryId,
    categoryName,
    trackId: currTrackId,
    trackName,
  }) => (
    { value: `${currCategoryId}:${currTrackId}`, label: `${categoryName}: ${trackName}` }
  )) || []

  return (
    <Box mb={20}>
      <Select
        clearable
        data={options}
        defaultValue={trackId}
        label="Track"
        mb={10}
        onChange={selectTrack}
        onSearchChange={trackOnSearchChange}
        searchable
      />

      <Button onClick={addTrack} disabled={trackId == null}>Add track</Button>
    </Box>
  )
}
