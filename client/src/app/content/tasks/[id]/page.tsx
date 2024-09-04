'use client'

import React, { useCallback, useEffect, useState } from 'react'
import {
  Box, Button, LoadingOverlay,
} from '@mantine/core'
import taskService, { FetchResponse, PrereqTaskType } from '@/services/tasks'
import ListOr from '@/components/ListOr'
import TitleAndButton from '@/components/TitleAndButton'
import MarkdownPreview from '@/components/MarkdownPreview'
import PrereqTaskSelect from '@/components/PrereqTaskSelect'
import PrereqTask from '@/components/PrereqTask'
import QuestionUrlPrompt from '@/components/QuestionUrlPrompt/page'

type Params = {
  params?: { id: string } | null
}

function makeKey({ taskId, prereqTaskId, prereqApproachId }: PrereqTaskType) {
  return `${taskId}:${prereqApproachId}:${prereqTaskId}`
}

export default function Page(params: Params) {
  const [isLoading, setIsLoading] = useState(true)
  const [response, setResponse] = useState<FetchResponse | null>(null)
  const taskId = params?.params?.id

  useEffect(() => {
    async function fetchData() {
      if (taskId == null) return
      const currResponse = await taskService.fetch(taskId)
      setResponse(currResponse)
      setIsLoading(false)
    }
    fetchData()
  }, [taskId, setResponse, setIsLoading])

  const refreshParent = useCallback(async () => {
    if (taskId == null) return
    // eslint-disable-next-line no-console
    console.log('refetching page ...')
    const currResponse = await taskService.fetch(taskId)
    setResponse(currResponse)
  }, [taskId, setResponse])

  const task = response?.data?.task
  const prereqTasks = response?.data?.prereqTasks || []

  return (
    <main>
      <Box pos="relative">
        <LoadingOverlay
          visible={isLoading}
          zIndex={1000}
          overlayProps={{ radius: 'sm', blur: 2 }}
        />

        {taskId && task && prereqTasks && (
          <>
            <TitleAndButton title={task.summary}>
              <Button>Edit</Button>
            </TitleAndButton>

            {task.questionUrl && <QuestionUrlPrompt questionUrl={task.questionUrl} />}

            <MarkdownPreview markdown={task.questionText || ''} />

            <PrereqTaskSelect taskId={taskId} refreshParent={refreshParent} />

            <ListOr title="Things that must be mastered" fallback="No prerequisites">
              {prereqTasks.map((currTask) => (
                <PrereqTask
                  key={makeKey(currTask)}
                  prereqTask={currTask}
                  refreshParent={refreshParent}
                />
              ))}
            </ListOr>
          </>
        )}
      </Box>
    </main>
  )
}
