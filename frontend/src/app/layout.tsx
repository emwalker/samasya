import React from 'react'
import './globals.css'
import { Inter } from 'next/font/google'
import Link from 'next/link'

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
        </nav>

        {children}
      </body>
    </html>
  )
}
