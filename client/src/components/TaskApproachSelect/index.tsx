'use client'

import React, { useCallback, useState } from 'react'
import { Box, Select } from '@mantine/core'
import { ApproachType, TaskType } from '@/types'
import taskService from '@/services/tasks'
import { handleError } from '@/app/handleResponse'

type Props = {
  label: string,
  setApproachId: (approachId: string | null) => void,
}

export default function TaskApproachSelect({
  label,
  setApproachId,
}: Props) {
  const [tasks, setTasks] = useState<TaskType[]>([])
  const [approches, setApproaches] = useState<ApproachType[]>([])
  const [selectedTask, setSelectedTask] = useState<TaskType | null>(null)
  const [selectedApproachId] = useState<string | null>(null)
  const taskOptions = tasks.map(({ id, summary }) => ({ value: id, label: summary }))
  const approachOptions = approches.map(({ id, summary }) => ({ value: id, label: summary }))

  const taskOnSearchChange = useCallback(async (searchString: string) => {
    const response = await taskService.list(searchString)
    const currTasks = response.data || []
    setTasks(currTasks)
  }, [setTasks])

  const selectTask = useCallback(async (taskId: string | null) => {
    if (taskId == null) {
      setApproachId(null)
      setApproaches([])
      return
    }

    const response = await taskService.fetch(taskId)
    handleError(response, 'Problem getting task details')
    setSelectedTask(response.data?.task || null)
    setApproaches(response.data?.approaches || [])
  }, [setSelectedTask, setApproachId, setApproaches])

  const selectedTaskId = selectedTask?.id || null

  return (
    <Box>
      <Select
        clearable
        data={taskOptions}
        defaultValue={selectedTask?.id}
        label={label}
        mb={20}
        onChange={selectTask}
        onSearchChange={taskOnSearchChange}
        placeholder="Select a task"
        searchable
      />

      {selectedTaskId && (
        <Select
          clearable
          data={approachOptions}
          defaultValue={selectedApproachId}
          label="Approach to learn"
          mb={20}
          onChange={setApproachId}
          placeholder="Select an approach"
          searchable
        />
      )}
    </Box>
  )
}
