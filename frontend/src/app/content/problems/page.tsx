import React from 'react'
import Link from 'next/link'
import { Problem } from '@/types'
import problemService from '@/services/problems'
import ListOr from '@/components/ListOr'
import styles from './styles.module.css'

function ProblemItem({ problem }: { problem: Problem }) {
  return (
    <Link href={`/content/problems/${problem.id}`}>
      {problem.summary}
    </Link>
  )
}

export default async function Page() {
  const problems = (await problemService.getList()).data

  return (
    <main>
      <h1 data-testid="page-name">Problems</h1>

      <ListOr title="Available problems" fallback="No problems">
        {
          problems.map((problem) => (
            <li className={styles.problem} key={problem.id}>
              <ProblemItem problem={problem} />
            </li>
          ))
        }
      </ListOr>

      <p>
        <Link href="/content/problems/new">Add a problem</Link>
      </p>
    </main>
  )
}
