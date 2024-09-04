import React, { useCallback, useEffect, useState } from 'react'
import {
  Badge,
  Box,
  Center,
  Table,
  Title,
} from '@mantine/core'
import approachService, { FetchData } from '@/services/approaches'
import { handleError } from '@/app/handleResponse'
import AddPrereqTask from '../AddPrereqTask'

type PrereqProps = {
  taskId: string,
  taskSummary: string,
  taskAction: string,
  approachId: string,
  approachSummary: string,
}

function labelForAction(action: string) {
  if (action === 'completeProblem') return 'Complete problem'
  return ''
}

function Prereq({
  taskId,
  taskSummary,
  taskAction,
  approachId,
  approachSummary,
}: PrereqProps) {
  return (
    <Table.Tr key={`${taskId}:${approachId}`}>
      <Table.Td>{taskSummary}</Table.Td>
      <Table.Td>{approachSummary}</Table.Td>
      <Table.Td align="center"><Badge>{labelForAction(taskAction)}</Badge></Table.Td>
    </Table.Tr>
  )
}

type Props = {
  taskId: string,
  approachId: string,
}

export default function ApproachView({ taskId, approachId }: Props) {
  const [fetchData, setFetchData] = useState<FetchData | null>(null)

  useEffect(() => {
    async function loadData() {
      const response = await approachService.fetch(approachId)
      handleError(response, 'Failed to update view')
      setFetchData(response?.data || null)
    }
    loadData()
  }, [approachId, setFetchData])

  const refreshParent = useCallback(async () => {
    // eslint-disable-next-line no-console
    console.log('refreshing view ...')
    const response = await approachService.fetch(approachId)
    handleError(response, 'Failed to update view')
    setFetchData(response?.data || null)
  }, [approachId, setFetchData])

  const prereqs = fetchData?.prereqs

  return (
    <Box key={`${taskId}:${approachId}`}>
      {prereqs && (
        <>
          <AddPrereqTask
            taskId={taskId}
            approachId={approachId}
            refreshParent={refreshParent}
          />

          <Title my={20} order={4}>Prerequisites</Title>

          <Table>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>Summary</Table.Th>
                <Table.Th>Approach</Table.Th>
                <Table.Th><Center>Action</Center></Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {prereqs.map(Prereq)}
            </Table.Tbody>
          </Table>
        </>
      )}
    </Box>
  )
}
