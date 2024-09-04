import React from 'react'
import Link from 'next/link'
import styles from './page.module.css'

export default function Home() {
  return (
    <main className={styles.main}>
      <h1>Content authoring</h1>

      <p>
        Go to the
        {' '}
        <Link href="/content/tasks">tasks</Link>
        {' '}
        page.
      </p>
    </main>
  )
}
