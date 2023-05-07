import styles from './page.module.css'

export default function Home() {
  return (
    <main className={styles.main}>
      <div className={styles.description} data-testid="hero">
        Samasya — build out your own skill tree
      </div>

      <p>
        Go to the <a href="/skills">skills</a> page.
      </p>
    </main>
  )
}
