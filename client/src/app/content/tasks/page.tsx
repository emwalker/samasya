'use client'

import React, { useEffect, useState } from 'react'
import Link from 'next/link'
import { Box, Button, Card } from '@mantine/core'
import { TaskType } from '@/types'
import TitleAndButton from '@/components/TitleAndButton'
import taskService, { ListData } from '@/services/tasks'
import ListOr from '@/components/ListOr'
import { handleError } from '@/app/handleResponse'
import classes from './page.module.css'

function Task({ id, summary }: TaskType) {
  return (
    <Card className={classes.card} key={id} mb={10}>
      <Link href={`/content/tasks/${id}`}>
        {summary}
      </Link>
    </Card>
  )
}

export default function Page() {
  const [listData, setListData] = useState<ListData | null>(null)

  useEffect(() => {
    async function fetchData() {
      const response = await taskService.list()
      handleError(response, 'Failed to fetch tasks')
      setListData(response?.data || null)
    }
    fetchData()
  }, [setListData])

  const tasks = listData || []

  return (
    <Box>
      <TitleAndButton title="Tasks">
        <Button component="a" href="/content/tasks/new">New</Button>
      </TitleAndButton>

      <ListOr fallback="No tasks">
        {tasks.map(Task)}
      </ListOr>
    </Box>
  )
}
