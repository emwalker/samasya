'use client'

import React, { useCallback, useState } from 'react'
import {
  Box, Button, ComboboxData, Select,
} from '@mantine/core'
import skillService from '@/services/skills'
import problemService from '@/services/problems'
import { handleError } from '@/app/handleResponse'

type Props = {
  problemId: string,
  refreshParent: () => void,
}

export default function PrereqSkills({ problemId, refreshParent }: Props) {
  const [options, setOptions] = useState<ComboboxData>([])
  const [selectedSkillId, setSelectedSkillId] = useState<string | null>(null)

  const onSearchChange = useCallback(async (searchString: string) => {
    const response = await skillService.list({ searchString })
    const skills = response?.data || []
    const currOptions = skills.map(({ id: value, summary: label }) => ({ value, label }))
    setOptions(currOptions)
  }, [setOptions])

  const addSkill = useCallback(async () => {
    if (selectedSkillId == null) return
    const response = await problemService.addSkill({
      problemId, approachId: null, prereqSkillId: selectedSkillId,
    })
    handleError(response, 'Failed to add skill')
    refreshParent()
  }, [problemId, selectedSkillId, refreshParent])

  return (
    <Box>
      <Select
        clearable
        data={options}
        defaultValue={selectedSkillId}
        label="Add a skill"
        mb={10}
        onChange={setSelectedSkillId}
        onSearchChange={onSearchChange}
        placeholder="Prerequisite skill"
        searchable
      />

      {selectedSkillId && <Button onClick={addSkill}>Add</Button>}
    </Box>
  )
}
