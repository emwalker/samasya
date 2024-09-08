'use client'

import React, { useEffect, useState } from 'react'
import {
  Badge,
  Box,
  Button,
  LoadingOverlay,
  Select,
} from '@mantine/core'
import taskService, { FetchData } from '@/services/tasks'
import TitleAndButton from '@/components/TitleAndButton'
import MarkdownPreview from '@/components/MarkdownPreview'
import QuestionUrlPrompt from '@/components/QuestionUrlPrompt/page'
import ApproachView from '@/components/ApproachView'
import { TaskType } from '@/types'
import { actionText, actionColor } from '@/helpers'

function showApproach({ action }: TaskType): boolean {
  return action === 'completeProblem'
}

type Props = {
  params?: { id: string } | null
}

export default function Page(props: Props) {
  const [fetchData, setFetchData] = useState<FetchData | null>(null)
  const [currentApproachId, setCurrentApproachId] = useState<string | null>(null)
  const taskId = props?.params?.id

  useEffect(() => {
    async function loadData() {
      if (taskId == null) return
      const response = await taskService.fetch(taskId)
      const data = response?.data || null
      const approachId = (data?.approaches || [])[0]?.id
      setFetchData(data)
      setCurrentApproachId(approachId)
    }
    loadData()
  }, [taskId, setFetchData])

  const task = fetchData?.task
  const approachOptions = fetchData?.approaches
    ?.map(({ id, summary }) => ({ value: id, label: summary })) || []

  return (
    <Box pos="relative">
      <LoadingOverlay
        visible={fetchData == null}
        zIndex={1000}
        overlayProps={{ radius: 'sm', blur: 2 }}
      />

      {taskId && task && (
        <>
          <TitleAndButton title={task.summary}>
            <Button
              variant="outline"
              component="a"
              href={`/content/tasks/${taskId}/edit`}
            >
              Edit
            </Button>
          </TitleAndButton>

          <Badge mb={20} color={actionColor(task.action)}>{actionText(task.action)}</Badge>

          <Box mb={30}>
            {task.questionUrl && <QuestionUrlPrompt questionUrl={task.questionUrl} />}
            {task.questionPrompt && <MarkdownPreview markdown={task.questionPrompt} />}
          </Box>

          {showApproach(task) && (
            <Select
              data={approachOptions}
              defaultValue={currentApproachId}
              label="Approach"
              mb={20}
              onChange={setCurrentApproachId}
            />
          )}

          {currentApproachId && <ApproachView taskId={taskId} approachId={currentApproachId} />}
        </>
      )}
    </Box>
  )
}
