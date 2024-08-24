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
        <Link href="/content/skills">skills</Link>
        {' '}
        page.
      </p>

      <p>
        Go to the
        {' '}
        <Link href="/content/problems">problems</Link>
        {' '}
        page.
      </p>
    </main>
  )
}
