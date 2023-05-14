import React from 'react'
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
        <a href="/skills">skills</a>
        {' '}
        page.
      </p>

      <p>
        Go to the
        {' '}
        <a href="/problems">problems</a>
        {' '}
        page.
      </p>
    </main>
  )
}
