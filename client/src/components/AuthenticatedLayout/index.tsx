'use client'

import React, { Suspense } from 'react'
import {
  Box,
  Group,
  rem,
  Title,
  Tooltip,
} from '@mantine/core'
import {
  IconChartArrows,
  IconCheckbox,
  IconHome2,
  IconPlant2,
} from '@tabler/icons-react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import classes from './index.module.css'
import '@/app/global.css'
import SearchBox from '../SearchBox'

type Props = {
  children: React.ReactNode
}

const asideLinks = [
  { icon: IconHome2, label: 'Home', href: '/' },
  { icon: IconCheckbox, label: 'Tasks', href: '/content/tasks' },
  { icon: IconChartArrows, label: 'Queues', href: '/learning/queues' },
]

function AuthenticatedLayout({ children }: Props) {
  const path = usePathname()

  const mainLinks = asideLinks.map((link) => (
    <Tooltip
      label={link.label}
      position="right"
      withArrow
      transitionProps={{ duration: 0 }}
      key={link.label}
    >
      <Link
        href={link.href}
        className={classes.link}
        data-active={link.href === path || undefined}
      >
        <Group>
          <link.icon style={{ width: rem(22), height: rem(22) }} stroke={1.5} />
          {link.label}
        </Group>
      </Link>
    </Tooltip>
  ))

  return (
    <div className={classes.container}>
      <nav className={classes.navbar}>
        <div className={classes.navbarMain}>
          <Group className={classes.logo} justify="left">
            <Link href="/" className="link">
              <IconPlant2 className={classes.linkIcon} stroke={1.5} />
              <Title order={2} className={classes.logoTitle}>Samasya</Title>
            </Link>
          </Group>

          <Suspense>
            <SearchBox />
          </Suspense>
        </div>
      </nav>

      <main className={classes.main}>
        <div className={classes.content}>
          <div className={classes.aside}>
            {mainLinks}
          </div>

          <Box className={classes.results}>
            {children}
          </Box>
        </div>
      </main>
    </div>
  )
}

export default AuthenticatedLayout
