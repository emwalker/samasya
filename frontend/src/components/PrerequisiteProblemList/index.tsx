import React from 'react'
import styles from './styles.module.css'

export default function PrerequisiteProblemList() {
  return (
    <div className={styles.component}>
      {/* eslint-disable-next-line jsx-a11y/label-has-associated-control */}
      <label>Prerequisite problems</label>

      <ul>
        <li>Some problem</li>
      </ul>
    </div>
  )
}
