import React from 'react'
import { Group, Title, Box } from '@mantine/core'
import {
  IconBrandCodesandbox,
} from '@tabler/icons-react'
import Link from 'next/link'
import classes from './index.module.css'
import '@/app/global.css'

type Props = {
  children: React.ReactNode
}

function AuthenticatedLayout({ children }: Props) {
  return (
    <div className={classes.container}>
      <nav className={classes.navbar}>
        <div className={classes.navbarMain}>
          <Group className={classes.logo} justify="left">
            <Link href="/" className="link">
              <IconBrandCodesandbox className={classes.linkIcon} stroke={1.5} />
              <Title order={2} className={classes.logoTitle}>Samasya</Title>
            </Link>
          </Group>

          <div className={classes.searchBox}>
            <span>Search box</span>
          </div>
        </div>
      </nav>

      <main className={classes.main}>
        <div className={classes.content}>
          <div className={classes.leftColumn} />

          <Box className={classes.results}>
            {children}
          </Box>
        </div>
      </main>
    </div>
  )
}

export default AuthenticatedLayout
