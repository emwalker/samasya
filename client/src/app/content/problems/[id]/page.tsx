'use client'

import React, { useCallback, useEffect, useState } from 'react'
import {
  Box, Button, LoadingOverlay,
} from '@mantine/core'
import problemService, { FetchResponse, PrereqSkillType } from '@/services/problems'
import ListOr from '@/components/ListOr'
import TitleAndButton from '@/components/TitleAndButton'
import MarkdownPreview from '@/components/MarkdownPreview'
import PrereqSkills from '@/components/PrereqSkills'
import PrereqSkill from '@/components/PrereqSkill'

type Params = {
  params?: { id: string } | null
}

function makeKey({ problemId, approachId, prereqSkillId }: PrereqSkillType) {
  return `${problemId}:${approachId}:${prereqSkillId}`
}

export default function Page(params: Params) {
  const [isLoading, setIsLoading] = useState(true)
  const [response, setResponse] = useState<FetchResponse | null>(null)
  const problemId = params?.params?.id

  useEffect(() => {
    async function fetchData() {
      if (problemId == null) return
      const currResponse = await problemService.fetch(problemId)
      setResponse(currResponse)
      setIsLoading(false)
    }
    fetchData()
  }, [problemId, setResponse, setIsLoading])

  const refreshParent = useCallback(async () => {
    if (problemId == null) return
    // eslint-disable-next-line no-console
    console.log('refetching page ...')
    const currResponse = await problemService.fetch(problemId)
    setResponse(currResponse)
  }, [problemId, setResponse])

  const problem = response?.data?.problem
  const prereqSkills = response?.data?.prereqSkills || []

  return (
    <main>
      <Box pos="relative">
        <LoadingOverlay
          visible={isLoading}
          zIndex={1000}
          overlayProps={{ radius: 'sm', blur: 2 }}
        />

        {problemId && problem && prereqSkills && (
          <>
            <TitleAndButton title={problem.summary}>
              <Button>Edit</Button>
            </TitleAndButton>

            <p>
              {problem.questionUrl}
            </p>

            <MarkdownPreview markdown={problem.questionText || ''} />

            <PrereqSkills problemId={problemId} refreshParent={refreshParent} />

            <ListOr title="Skills that must be mastered" fallback="No skills">
              {prereqSkills.map((skill) => (
                <PrereqSkill
                  key={makeKey(skill)}
                  prereqSkill={skill}
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
