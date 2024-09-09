'use client'

import React, { useEffect, useState } from 'react'
import { useSearchParams } from "next/navigation"
import { Badge, Box, Card, Group, Title } from '@mantine/core'
import Link from 'next/link'
import classes from './page.module.css'
import searchService, {
  SearchData,
  SearchItemType,
  SearchItemTypeEnum,
} from '@/services/search'
import { ApiResponse } from '@/types'
import { handleError } from '../handleResponse'

function colorFor(type: SearchItemTypeEnum) {
  if (type === 'queue') return 'cyan.4'
  if (type === 'task') return 'orange.4'
  return 'green'
}

function hrefFor(type: SearchItemTypeEnum, id: string) {
  if (type === 'queue') return `/learning/queues/${id}`
  if (type === 'task') return `/content/tasks/${id}`
  return ''
}

function Result({ summary, type, id }: SearchItemType) {
  const href = hrefFor(type, id)
  return (
    <Card mt={10} key={id}>
      <Group>
        <Link className={classes.link} href={href}>{summary}</Link>
        <Badge color={colorFor(type)}>{type}</Badge>
      </Group>
    </Card>
  )
}

export default function Page() {
  const params = useSearchParams()
  const [response, setResponse] = useState<ApiResponse<SearchData> | null>(null)
  const searchString = params.get('q') || ''

  useEffect(() => {
    async function loadData() {
      const currResponse = await searchService.search(searchString)
      handleError(currResponse, 'Failed to fetch search results')
      setResponse(currResponse)
    }
    loadData()
  }, [searchString])

  const results = response?.data?.results || []

  return (
    <Box>
      <Title>Results</Title>

      {results.map(Result)}
    </Box>
  )
}
