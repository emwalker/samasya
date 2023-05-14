import React from 'react'
import Link from 'next/link'
import styles from './page.module.css'

export default function Home() {
  return (
    <main className={styles.main}>
      <div className={styles.description} data-testid="hero">
        Samasya — build out your own skill tree
      </div>

      <p>
        Go to the
        {' '}
        <Link href="/skills">skills</Link>
        {' '}
        page.
      </p>

      <p>
        Go to the
        {' '}
        <Link href="/problems">problems</Link>
        {' '}
        page.
      </p>
    </main>
  )
}
