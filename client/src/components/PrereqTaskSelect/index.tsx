import React, { useCallback, useState } from 'react'
import {
  Box, Button, ComboboxData, Select,
} from '@mantine/core'
import taskService from '@/services/tasks'
import { notifications } from '@mantine/notifications'

type Fn = (options: ComboboxData) => void

async function updatePrereqProblems(
  setPrereqProblemOptions: Fn,
  taskId: string,
  searchString: string,
) {
  const response = await taskService.availablePrereqTasks(taskId, searchString || '')
  const options = response?.data?.map(({ id: value, summary: label }) => ({ value, label })) || []
  setPrereqProblemOptions(options || [])
}

type Props = {
  taskId: string,
  refreshParent: () => void,
}

export default function PrereqProblems({ taskId, refreshParent }: Props) {
  const [prereqProblemOptions, setPrereqProblemOptions] = useState<ComboboxData>([])
  const [prereqApproachOptions, setPrereqApproachOptions] = useState<ComboboxData>([])
  const [prereqTaskId, setPrereqProblemId] = useState<string | null>(null)
  const [prereqApproachId, setPrereqApproachId] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  const updateSearch = useCallback(async (searchString: string | null) => {
    const search = searchString || ''
    if (isLoading || search !== '') {
      updatePrereqProblems(setPrereqProblemOptions, taskId, search)
    }
    setIsLoading(false)
  }, [setPrereqProblemOptions, taskId, isLoading])

  const onProblemSelect = useCallback(async (selectedProblemId: string | null) => {
    setPrereqProblemId(selectedProblemId)
    setPrereqApproachId(null)

    if (selectedProblemId == null) {
      setPrereqApproachOptions([])
    } else {
      const response = await taskService.fetch(selectedProblemId)
      const options = response.data?.approaches
        ?.map(({ name: label, id: value }) => ({ label, value }))
      setPrereqApproachOptions(options || [])
    }
  }, [setPrereqApproachId, setPrereqProblemId, setPrereqApproachOptions])

  const addPrereqProblem = useCallback(async () => {
    if (prereqTaskId == null || prereqApproachId == null) {
      notifications.show({
        title: 'Something happened',
        color: 'red',
        position: 'top-center',
        message: 'Cannot add a prequisite problem without an id',
      })
      return
    }
    await taskService.addPrereqTask({ taskId, prereqTaskId, prereqApproachId })

    setPrereqProblemId(null)
    setPrereqApproachId(null)
    setPrereqProblemOptions([])
    setPrereqApproachOptions([])
    refreshParent()
  }, [
    prereqApproachId,
    prereqTaskId,
    refreshParent,
    setPrereqApproachId,
    setPrereqApproachOptions,
    setPrereqProblemId,
    setPrereqProblemOptions,
    taskId,
  ])

  return (
    <Box mb={10}>
      <Select
        allowDeselect
        clearable
        data={prereqProblemOptions}
        defaultValue={prereqTaskId}
        label="Add a problem"
        mb={10}
        onChange={onProblemSelect}
        filter={({ options }) => options}
        onSearchChange={updateSearch}
        placeholder="Select a problem"
        searchable
      />

      {
        prereqTaskId && (
          <>
            <Select
              data={prereqApproachOptions}
              mb={10}
              defaultValue={prereqApproachId}
              placeholder="Select an approach (optional)"
              onChange={setPrereqApproachId}
            />

            <Button onClick={addPrereqProblem}>Add</Button>
          </>
        )
      }
    </Box>
  )
}
