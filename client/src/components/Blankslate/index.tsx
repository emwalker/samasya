import React from 'react'
import { Card } from '@mantine/core'
import classes from './index.module.css'

type Props = {
  children: React.ReactNode,
}

export default function Blankslate({ children }: Props) {
  return (
    <Card withBorder radius={4} className={classes.card}>
      {children}
    </Card>
  )
}
