import React from 'react'
import './globals.css'
import { Inter } from 'next/font/google'
import Link from 'next/link'
import styles from './layout.module.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'Samasya',
  description: 'Build out your own skill tree',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <nav className="topnav">
          <Link href="/">Home</Link>

          <div className={styles.rightNav}>
            <Link href="/content">Content</Link>
            {' '}
            <Link href="/learning">Learning</Link>
          </div>
        </nav>

        {children}
      </body>
    </html>
  )
}
