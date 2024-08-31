'use client'

import React, { useCallback, useEffect, useState } from 'react'
import skillService, { FetchResponse, PrereqProblemType } from '@/services/skills'
import {
  Box, Button, LoadingOverlay,
} from '@mantine/core'
import PrereqProblems from '@/components/PrereqProblems'
import ListOr from '@/components/ListOr'
import PrereqProblem from '@/components/PrereqProblem'
import MarkdownPreview from '@/components/MarkdownPreview'
import TitleAndButton from '@/components/TitleAndButton'

function makeKey({ skillId, prereqProblemId, prereqApproachId }: PrereqProblemType) {
  return `${skillId}:${prereqProblemId}:${prereqApproachId}`
}

type Props = {
  params: {
    id: string
  } | null
}

export default function Page(props: Props) {
  const [isLoading, setIsLoading] = useState(true)
  const [response, setResponse] = useState<FetchResponse | null>(null)
  const skillId = props?.params?.id

  useEffect(() => {
    if (skillId == null) return
    skillService.fetch(skillId).then(setResponse)
    setIsLoading(false)
  }, [skillId, setResponse, setIsLoading])

  const refreshParent = useCallback(() => {
    if (skillId == null) return
    // eslint-disable-next-line no-console
    console.log('refetching page ...')
    skillService.fetch(skillId).then(setResponse)
  }, [skillId])

  const skill = response?.data?.skill
  const prereqProblems = response?.data?.prereqProblems

  return (
    <main>
      <Box pos="relative">
        <LoadingOverlay
          visible={isLoading}
          zIndex={1000}
          overlayProps={{ radius: 'sm', blur: 2 }}
        />

        {skillId && skill && prereqProblems && (
          <>
            <Box mb={20}>
              <TitleAndButton title={skill.summary}>
                <Button
                  component="a"
                  mr={3}
                  href={`/content/skills/${skillId}/edit`}
                >
                  Edit
                </Button>
              </TitleAndButton>

              <MarkdownPreview markdown={skill.description || ''} />
            </Box>

            <PrereqProblems skillId={skillId} refreshParent={refreshParent} />

            <Box mb={20}>
              <ListOr title="Problems that must be mastered" fallback="No problems">
                {
                  prereqProblems.map((prereqProblem) => (
                    <PrereqProblem
                      key={makeKey(prereqProblem)}
                      prereqProblem={prereqProblem}
                      refreshParent={refreshParent}
                    />
                  ))
                }
              </ListOr>
            </Box>
          </>
        )}
      </Box>
    </main>
  )
}
