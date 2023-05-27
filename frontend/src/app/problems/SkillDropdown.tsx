import React, { useCallback } from 'react'
import AsyncSelect from 'react-select/async'
import { MultiValue } from 'react-select'

export type Skill = {
  id: string,
  description: string,
}

type Props = {
  initialSkills: Skill[],
  setSkills: (skills: Skill[]) => void,
}

type Option = {
  value: string,
  label: string,
}

async function fetchSkills(searchText: string): Promise<Option[]> {
  const response = await fetch(`http://localhost:8000/api/v1/skills?q=${searchText}`)
  if (!response.ok) {
    return []
  }
  const data = (await response.json()).data as Skill[]
  return data.map(({ id, description }) => ({ value: id, label: description }))
}

const components = {
  NoOptionsMessage: () => <div>No skills</div>,
  LoadingMessage: () => <div>Loading ...</div>,
  LoadingIndicator: () => null,
}

export default function SkillDropdown({ initialSkills, setSkills }: Props) {
  const onChange = useCallback(
    (newValue: MultiValue<Option>) => {
      const newSkills = newValue.map(({ value, label }) => ({ id: value, description: label }))
      setSkills(newSkills)
    },
    [setSkills],
  )

  const skillsLoadOptions = useCallback(fetchSkills, [fetchSkills])
  const defaultValue = initialSkills.map(
    ({ id, description }) => ({ value: id, label: description }),
  )

  return (
    <AsyncSelect
      cacheOptions
      components={components}
      defaultOptions
      defaultValue={defaultValue}
      instanceId="skill-dropdown"
      isMulti
      loadOptions={skillsLoadOptions}
      onChange={onChange}
    />
  )
}
