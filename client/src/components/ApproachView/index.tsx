import React, { useCallback, useEffect, useState } from 'react'
import {
  Badge,
  Box,
  Center,
  Table,
  Title,
} from '@mantine/core'
import Link from 'next/link'
import approachService, { FetchData } from '@/services/approaches'
import { handleError } from '@/app/handleResponse'
import { actionText, actionColor } from '@/helpers'
import { TaskAction } from '@/types'
import AddPrereqTask from '../AddPrereqTask'

type PrereqProps = {
  taskId: string,
  taskSummary: string,
  taskAction: TaskAction,
  approachId: string,
  approachSummary: string,
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
      <Table.Td><Link href={`/content/tasks/${taskId}`}>{taskSummary}</Link></Table.Td>
      <Table.Td>{approachSummary}</Table.Td>
      <Table.Td align="center">
        <Badge color={actionColor(taskAction)}>{actionText(taskAction)}</Badge>
      </Table.Td>
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
