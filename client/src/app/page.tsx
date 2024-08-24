import React from 'react'
import Link from 'next/link'
import styles from './page.module.css'

export default function Home() {
  return (
    <main className={styles.main}>
      <div className={styles.description} data-testid="hero">
        Samasya — build out your own skill tree
      </div>

      Home page
      <p>
        Go to
        {' '}
        <Link href="/content">content authoring</Link>
        .
      </p>

      <p>
        Go to the
        {' '}
        <Link href="/learning">learning</Link>
        {' '}
        page.
      </p>
    </main>
  )
}
