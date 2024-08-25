'use client'

import React, { useCallback, useEffect, useState } from 'react'
// import { notFound } from 'next/navigation'
import skillService, { GetResponse, PrereqProblemType } from '@/services/skills'
import problemService from '@/services/problems'
import {
  Box, Button, ComboboxData, LoadingOverlay, Select,
} from '@mantine/core'
import ListOr from '@/components/ListOr'
import { notifications } from '@mantine/notifications'
import PrereqProblem from '@/components/PrereqProblem'
import MarkdownPreview from '@/components/MarkdownPreview'
import TitleAndButton from '@/components/TitleAndButton'

type PrereqProblemsProps = {
  skillId: string,
  refreshParent: () => void,
}

type Fn = (options: ComboboxData) => void

async function updatePrereqProblems(setPrereqProblemOptions: Fn, searchString: string) {
  const response = await problemService.getList({ searchString: searchString || '' })
  const options = response.data.map(({ id: value, summary: label }) => ({ value, label }))
  setPrereqProblemOptions(options || [])
}

function PrereqProblems({ skillId, refreshParent }: PrereqProblemsProps) {
  const [prereqProblemOptions, setPrereqProblemOptions] = useState<ComboboxData>([])
  const [prereqApproachOptions, setPrereqApproachOptions] = useState<ComboboxData>([])
  const [prereqProblemId, setPrereqProblemId] = useState<string | null>(null)
  const [prereqApproachId, setPrereqApproachId] = useState<string | null>(null)

  useEffect(() => {
    updatePrereqProblems(setPrereqProblemOptions, '')
  }, [setPrereqProblemOptions])

  const onProblemSearchChange = useCallback(async (searchString: string | null) => {
    updatePrereqProblems(setPrereqProblemOptions, searchString || '')
  }, [setPrereqProblemOptions])

  const onProblemSelect = useCallback(async (selectedProblemId: string | null) => {
    setPrereqApproachId(null)

    if (selectedProblemId == null) {
      setPrereqProblemId(null)
      setPrereqApproachOptions([])
    } else {
      const response = await problemService.get(selectedProblemId)
      const options = response.data?.approaches
        ?.map(({ name: label, id: value }) => ({ label, value }))
      setPrereqProblemId(selectedProblemId)
      setPrereqApproachOptions(options || [])
    }
  }, [setPrereqApproachOptions, setPrereqProblemId])

  const addPrereqProblem = useCallback(async () => {
    if (prereqProblemId == null) {
      notifications.show({
        title: 'Something happened',
        color: 'red',
        position: 'top-center',
        message: 'Cannot add a prequisite problem without an id',
      })
      return
    }
    await skillService.addProblem({ skillId, prereqProblemId, prereqApproachId })

    refreshParent()
    setPrereqProblemId(null)
    setPrereqApproachOptions([])
  }, [
    prereqApproachId,
    prereqProblemId,
    refreshParent,
    setPrereqApproachOptions,
    setPrereqProblemId,
    skillId,
  ])

  return (
    <Box mb={10}>
      <Select
        data={prereqProblemOptions}
        mb={10}
        label="Add a problem"
        onChange={onProblemSelect}
        onSearchChange={onProblemSearchChange}
        placeholder="Select a problem"
        value={prereqProblemId}
      />

      {
        prereqProblemId && (
          <>
            <Select
              data={prereqApproachOptions}
              mb={10}
              value={prereqApproachId}
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
  const [response, setResponse] = useState<GetResponse | null>(null)
  const skillId = props?.params?.id

  useEffect(() => {
    if (skillId == null) return
    skillService.get(skillId).then(setResponse)
    setIsLoading(false)
  }, [skillId, setResponse, setIsLoading])

  const refreshParent = useCallback(() => {
    if (skillId == null) return
    // eslint-disable-next-line no-console
    console.log('refetching page ...')
    skillService.get(skillId).then(setResponse)
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
