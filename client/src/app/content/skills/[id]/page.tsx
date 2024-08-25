'use client'

import React, { useCallback, useEffect, useState } from 'react'
import { notFound } from 'next/navigation'
import skillService, { GetResponse } from '@/services/skills'
import problemService from '@/services/problems'
import {
  Box, Button, ComboboxData, Select,
  Title,
} from '@mantine/core'
import ListOr from '@/components/ListOr'
import { notifications } from '@mantine/notifications'
import PrereqProblem from '@/components/PrereqProblem'

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
      <Title order={5} mb={10}>Add a problem</Title>

      <Select
        data={prereqProblemOptions}
        mb={10}
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

type Props = {
  params: {
    id: string
  } | null
}

export default function Page(props: Props) {
  const [response, setResponse] = useState<GetResponse | null>(null)
  const skillId = props?.params?.id

  useEffect(() => {
    if (skillId == null) return
    skillService.get(skillId).then(setResponse)
  }, [skillId, setResponse])

  const refreshParent = useCallback(() => {
    if (skillId == null) return
    // eslint-disable-next-line no-console
    console.log('refetching page ...')
    skillService.get(skillId).then(setResponse)
  }, [skillId])

  if (skillId == null || response == null) {
    return <div>Loading ...</div>
  }

  if (response.data == null) {
    return notFound()
  }

  const { data: { skill: { summary }, prereqProblems } } = response

  return (
    <main>
      <Box mb={20}>
        <p>{summary}</p>

        <Button
          component="a"
          mr={3}
          href={`/content/skills/${skillId}/edit`}
        >
          Edit
        </Button>
      </Box>

      <PrereqProblems skillId={skillId} refreshParent={refreshParent} />

      <Box mb={20}>
        <ListOr title="Problems that must be mastered" fallback="No problems">
          {
            prereqProblems.map((prereqProblem) => {
              const key = `${prereqProblem.skillId}:${prereqProblem.prereqProblemId}:${prereqProblem.prereqApproachId}`
              return (
                <PrereqProblem
                  key={key}
                  prereqProblem={prereqProblem}
                  refreshParent={refreshParent}
                />
              )
            })
          }
        </ListOr>
      </Box>
    </main>
  )
}
