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
  const [compoundKey, setCompoundKey] = useState<string | null>(null)

  const trackOnSearchChange = useCallback(async (searchString: string) => {
    const currResponse = await queueService.availableTracks(queueId, searchString)
    handleError(currResponse, 'Failed to get available tracks')
    setResponse(currResponse)
  }, [setResponse, queueId])

  const addTrack = useCallback(async () => {
    if (compoundKey == null) return
    const [categoryId, trackId] = compoundKey.split(':')
    const currResponse = await queueService.addTrack(queueId, { queueId, trackId, categoryId })
    handleError(currResponse, 'Failed to add track')
    setCompoundKey(null)
    refreshParent()
  }, [refreshParent, compoundKey, queueId])

  const options = response?.data?.map(({
    categoryId: currCategoryId,
    categoryName,
    trackId: currTrackId,
    trackName,
  }) => (
    { value: `${currCategoryId}:${currTrackId}`, label: `${categoryName}: ${trackName}` }
  )) || []

  return (
    <Box mb={20} key={compoundKey}>
      <Select
        clearable
        data={options}
        defaultValue={compoundKey}
        label="Track"
        mb={10}
        onChange={setCompoundKey}
        onSearchChange={trackOnSearchChange}
        searchable
      />

      <Button onClick={addTrack} disabled={compoundKey == null}>Add track</Button>
    </Box>
  )
}
