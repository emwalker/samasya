import { Box, Button } from '@mantine/core'
import React, { useCallback, useState } from 'react'
import taskService from '@/services/tasks'
import approachService from '@/services/approaches'
import { handleError } from '@/app/handleResponse'
import TaskApproachSelect from '../TaskApproachSelect'

type AddPrereqApproachProps = {
  addPrereq: () => void,
  disabled: boolean,
}

function AddButton({ addPrereq, disabled }: AddPrereqApproachProps) {
  return (
    <Button mt={10} disabled={disabled} onClick={addPrereq}>Add</Button>
  )
}

type Props = {
  taskId: string,
  approachId: string,
  refreshParent: () => void,
}

export default function AddPrereqTask({ taskId, approachId, refreshParent }: Props) {
  const [prereqTaskId, setPrereqTaskId] = useState<string | null>(null)
  const [prereqApproachId, setPrereqApproachId] = useState<string | null>(null)

  const searchTasks = useCallback(
    async (searchString: string) => approachService.availablePrereqs(approachId, searchString),
    [approachId],
  )

  const addPrereq = useCallback(async () => {
    if (taskId == null || approachId == null || prereqTaskId == null || prereqApproachId == null) {
      return
    }

    const payload = {
      taskId,
      approachId,
      prereqTaskId,
      prereqApproachId,
    }
    const response = await taskService.addPrereq(payload)
    handleError(response, 'Failed to add prerequisite')
    setPrereqApproachId(null)
    setPrereqTaskId(null)
    refreshParent()
  }, [
    approachId,
    prereqApproachId,
    prereqTaskId,
    refreshParent,
    setPrereqApproachId,
    setPrereqTaskId,
    taskId,
  ])

  return (
    <Box>
      <TaskApproachSelect
        taskId={prereqTaskId}
        approachId={prereqApproachId}
        setTaskId={setPrereqTaskId}
        setApproachId={setPrereqApproachId}
        searchTasks={searchTasks}
      />

      <AddButton addPrereq={addPrereq} disabled={prereqApproachId == null} />
    </Box>
  )
}
