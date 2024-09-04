'use client'

import React, { useCallback, useState } from 'react'
import { Box, Select } from '@mantine/core'
import { ApiResponse, ApproachType, TaskType } from '@/types'
import taskService from '@/services/tasks'
import { AvailableData } from '@/services/approaches'
import { handleError } from '@/app/handleResponse'

type Props = {
  approachId: string | null,
  taskId: string | null,
  setApproachId: (approachId: string | null) => void,
  setTaskId: (taskId: string | null) => void,
  searchTasks: (searchString: string) => Promise<ApiResponse<AvailableData>>,
}

export default function TaskApproachSelect({
  approachId,
  setApproachId,
  setTaskId,
  taskId,
  searchTasks,
}: Props) {
  const [tasks, setTasks] = useState<TaskType[]>([])
  const [approaches, setApproaches] = useState<ApproachType[]>([])
  const taskOptions = tasks.map(({ id, summary }) => ({ value: id, label: summary }))
  const approachOptions = approaches.map(({ id, summary }) => ({ value: id, label: summary }))

  const taskOnSearchChange = useCallback(async (searchString: string) => {
    const response = await searchTasks(searchString)
    const currTasks = response.data || []
    setTasks(currTasks)
  }, [setTasks, searchTasks])

  const selectTask = useCallback(async (currTaskId: string | null) => {
    if (currTaskId == null) {
      setApproachId(null)
      setApproaches([])
      return
    }

    const response = await taskService.fetch(currTaskId)
    const initialApproaches = response.data?.approaches || []
    const initialApproachId = initialApproaches[0]?.id

    handleError(response, 'Problem getting task details')
    setApproaches(initialApproaches)
    setApproachId(initialApproachId)
    setTaskId(currTaskId)
  }, [setApproachId, setApproaches, setTaskId])

  return (
    <Box mb={10} key={`${taskId}:${approachId}`}>
      <Select
        clearable
        data={taskOptions}
        defaultValue={taskId}
        label="Add a prerequisite"
        mb={10}
        onChange={selectTask}
        onSearchChange={taskOnSearchChange}
        placeholder="Choose a task"
        searchable
      />

      {taskId && (
        <Select
          clearable
          data={approachOptions}
          defaultValue={approachId}
          label="Approach that must be used"
          onChange={setApproachId}
          placeholder="Choose an approach"
          searchable
        />
      )}
    </Box>
  )
}
