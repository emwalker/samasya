import React from 'react'
import Link from 'next/link'
import styles from './page.module.css'

export default function Home() {
  return (
    <main className={styles.main}>
      <h1>Learning</h1>

      Go to the <Link href="/learning/queues">problem queues</Link> page.
    </main>
  )
}
