import React, { useCallback } from 'react'
import AsyncSelect from 'react-select/async'
import problemService from '@/services/problems'
import { SingleValue } from 'react-select'
import { ProblemSlice } from '@/types'
import styles from './styles.module.css'

type Props = {
  initialProblems: ProblemSlice[],
  label: string,
  setProblem: (problem: ProblemSlice | null) => void,
}

type Option = {
  value: string,
  label: string,
}

async function fetchProblems(searchString: string): Promise<Option[]> {
  const { data } = await problemService.getList({ searchString })
  return data.map(({ id, summary }) => ({ value: id, label: summary }))
}

const components = {
  NoOptionsMessage: () => <div>No skills</div>,
  LoadingMessage: () => <div>Loading ...</div>,
  LoadingIndicator: () => null,
}

export default function ProblemList({
  label,
  initialProblems,
  setProblem,
}: Props) {
  const onChange = useCallback(
    (newValue: SingleValue<Option>) => {
      const problem = newValue == null
        ? null
        : { id: newValue.value, summary: newValue.label }
      setProblem(problem)
    },
    [setProblem],
  )

  const loadOptions = useCallback(fetchProblems, [fetchProblems])
  const defaultValue = initialProblems.map(
    ({ id, summary }) => ({ value: id, label: summary }),
  )

  return (
    <div className={styles.component}>
      {/* eslint-disable-next-line jsx-a11y/label-has-associated-control */}
      <label>{label}</label>

      <AsyncSelect
        cacheOptions
        components={components}
        defaultOptions
        defaultValue={defaultValue}
        instanceId="skill-dropdown"
        isMulti={false}
        loadOptions={loadOptions}
        onChange={onChange}
      />
    </div>
  )
}
