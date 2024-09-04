import { Box, Title } from '@mantine/core'
import React from 'react'
import classes from './index.module.css'

type Props = {
  title: string,
  children: React.ReactNode,
}

export default function TitleAndButton({ title, children }: Props) {
  return (
    <Box mb={20} className={classes.articleHeader}>
      <Title className={classes.title}>{title}</Title>

      <div className={classes.buttons}>
        {children}
      </div>
    </Box>
  )
}
