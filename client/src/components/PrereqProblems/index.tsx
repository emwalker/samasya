import React, { useCallback, useState } from 'react'
import {
  Box, Button, ComboboxData, Select,
} from '@mantine/core'
import problemService from '@/services/problems'
import skillService from '@/services/skills'
import { notifications } from '@mantine/notifications'

type PrereqProblemsProps = {
  skillId: string,
  refreshParent: () => void,
}

type Fn = (options: ComboboxData) => void

async function updatePrereqProblems(
  setPrereqProblemOptions: Fn,
  skillId: string,
  searchString: string,
) {
  const response = await skillService.availablePrereqProblems(skillId, searchString || '')
  const options = response.data.map(({ id: value, summary: label }) => ({ value, label }))
  setPrereqProblemOptions(options || [])
}

export default function PrereqProblems({ skillId, refreshParent }: PrereqProblemsProps) {
  const [prereqProblemOptions, setPrereqProblemOptions] = useState<ComboboxData>([])
  const [prereqApproachOptions, setPrereqApproachOptions] = useState<ComboboxData>([])
  const [prereqProblemId, setPrereqProblemId] = useState<string | null>(null)
  const [prereqApproachId, setPrereqApproachId] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  const updateSearch = useCallback(async (searchString: string | null) => {
    const search = searchString || ''
    if (isLoading || search !== '') {
      updatePrereqProblems(setPrereqProblemOptions, skillId, search)
    }
    setIsLoading(false)
  }, [setPrereqProblemOptions, skillId, isLoading])

  const onProblemSelect = useCallback(async (selectedProblemId: string | null) => {
    setPrereqProblemId(selectedProblemId)
    setPrereqApproachId(null)

    if (selectedProblemId == null) {
      setPrereqApproachOptions([])
    } else {
      const response = await problemService.fetch(selectedProblemId)
      const options = response.data?.approaches
        ?.map(({ name: label, id: value }) => ({ label, value }))
      setPrereqApproachOptions(options || [])
    }
  }, [setPrereqApproachId, setPrereqProblemId, setPrereqApproachOptions])

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

    setPrereqProblemId(null)
    setPrereqApproachId(null)
    setPrereqProblemOptions([])
    setPrereqApproachOptions([])
    refreshParent()
  }, [
    prereqApproachId,
    prereqProblemId,
    refreshParent,
    setPrereqApproachId,
    setPrereqApproachOptions,
    setPrereqProblemId,
    setPrereqProblemOptions,
    skillId,
  ])

  return (
    <Box mb={10}>
      <Select
        allowDeselect
        clearable
        data={prereqProblemOptions}
        defaultValue={prereqProblemId}
        label="Add a problem"
        mb={10}
        onChange={onProblemSelect}
        filter={({ options }) => options}
        onSearchChange={updateSearch}
        placeholder="Select a problem"
        searchable
      />

      {
        prereqProblemId && (
          <>
            <Select
              data={prereqApproachOptions}
              mb={10}
              defaultValue={prereqApproachId}
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
