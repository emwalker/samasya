import React from 'react'
import { ComboboxData, Select } from '@mantine/core'
import styles from './styles.module.css'

type Props = {
  initialProblems: ComboboxData,
  label: string,
  setProblem: (problemId: string | null) => void,
}

export default function ProblemList({
  label,
  initialProblems,
  setProblem,
}: Props) {
  return (
    <div className={styles.component}>
      {/* eslint-disable-next-line jsx-a11y/label-has-associated-control */}
      <label>{label}</label>

      <Select
        data={initialProblems}
        onChange={(problemId) => setProblem(problemId)}
      />
    </div>
  )
}
