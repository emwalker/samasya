import React, { useCallback } from 'react'
import AsyncSelect from 'react-select/async'
import { MultiValue } from 'react-select'
import { Skill } from '@/types'
import styles from './styles.module.css'

type Props = {
  initialPrerequisiteSkills: Skill[],
  setPrerequisiteSkills: (skills: Skill[]) => void,
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
  return data.map(({ id, summary }) => ({ value: id, label: summary }))
}

const components = {
  NoOptionsMessage: () => <div>No skills</div>,
  LoadingMessage: () => <div>Loading ...</div>,
  LoadingIndicator: () => null,
}

export default function SkillMultiSelect({
  initialPrerequisiteSkills,
  setPrerequisiteSkills,
}: Props) {
  const onChange = useCallback(
    (newValue: MultiValue<Option>) => {
      const newSkills = newValue.map(({ value, label }) => ({ id: value, summary: label }))
      setPrerequisiteSkills(newSkills)
    },
    [setPrerequisiteSkills],
  )

  const loadOptions = useCallback(fetchSkills, [fetchSkills])
  const defaultValue = initialPrerequisiteSkills.map(
    ({ id, summary }) => ({ value: id, label: summary }),
  )

  return (
    <div className={styles.component}>
      {/* eslint-disable-next-line jsx-a11y/label-has-associated-control */}
      <label>Prerequisite skills</label>

      <AsyncSelect
        cacheOptions
        components={components}
        defaultOptions
        defaultValue={defaultValue}
        instanceId="skill-dropdown"
        isMulti
        loadOptions={loadOptions}
        onChange={onChange}
      />
    </div>
  )
}
