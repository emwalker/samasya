'use client'

import React, { useEffect, useState } from 'react'
import {
  Box, Button, Card, LoadingOverlay,
} from '@mantine/core'
import problemService, { FetchResponse } from '@/services/problems'
import { SkillType } from '@/types'
import ListOr from '@/components/ListOr'
import TitleAndButton from '@/components/TitleAndButton'
import MarkdownPreview from '@/components/MarkdownPreview'

function PrerequisiteSkill({ id, summary }: SkillType) {
  return (
    <Card key={id}>
      {summary}
    </Card>
  )
}

type Params = {
  params?: { id: string } | null
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

        {problem && prereqSkills && (
          <>
            <TitleAndButton title={problem.summary}>
              <Button>Edit</Button>
            </TitleAndButton>

            <p>
              {problem.questionUrl}
            </p>

            <MarkdownPreview markdown={problem.questionText || ''} />

            <ListOr title="Prequisite skills" fallback="No skills">
              {prereqSkills.map(PrerequisiteSkill)}
            </ListOr>
          </>
        )}
      </Box>
    </main>
  )
}
