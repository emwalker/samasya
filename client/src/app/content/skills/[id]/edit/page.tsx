'use client'

import React, {
  ChangeEvent, useCallback, useEffect, useState,
} from 'react'
import skillService from '@/services/skills'
import { notFound, useRouter } from 'next/navigation'
import {
  Box, Button, Textarea, TextInput, Title,
} from '@mantine/core'
import { notifications } from '@mantine/notifications'
import MarkdownPreview from '@/components/MarkdownPreview'
import Link from 'next/link'

type Props = {
  params: {
    id: string
  } | null
}

export default function Page(props: Props) {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState<boolean>(true)
  const [summary, setSummary] = useState<string | null>(null)
  const [description, setDescription] = useState<string | null>(null)
  const skillId = props?.params?.id

  useEffect(() => {
    async function fetchData() {
      if (skillId == null) return
      const response = await skillService.fetch(skillId)
      if (response.data?.skill == null) return
      const { data: { skill: { summary: currSummary, description: currDescription } } } = response
      setSummary(currSummary || '')
      setDescription(currDescription || '')
      setIsLoading(false)
    }
    fetchData()
  }, [skillId, setSummary])

  const summaryOnChange = useCallback((event: ChangeEvent<HTMLInputElement>) => {
    setSummary(event.target?.value)
  }, [setSummary])

  const descriptionOnChange = useCallback((event: ChangeEvent<HTMLTextAreaElement>) => {
    const markdown = event.target?.value
    setDescription(markdown)
  }, [setDescription])

  const updateSkill = useCallback(async () => {
    if (skillId == null || summary == null) return
    await skillService.update(skillId, { summary, description })
    router.push(`/content/skills/${skillId}`)
    notifications.show({
      title: 'Skill saved',
      position: 'top-center',
      message: 'Skill has been saved',
      color: 'blue',
    })
  }, [skillId, summary, description, router])

  if (isLoading) return <div>Loading ...</div>
  if (summary == null) return notFound()

  return (
    <main>
      <Box mb={20}>
        <Title mb={20} order={1}>{summary}</Title>

        <TextInput
          defaultValue={summary}
          label="Summary"
          mb={10}
          onChange={summaryOnChange}
          placeholder="Summary of skill"
        />

        <Textarea
          defaultValue={description || ''}
          label="Description"
          resize="vertical"
          mb={10}
          rows={6}
          onChange={descriptionOnChange}
          placeholder="Description"
        />

        <MarkdownPreview markdown={description || ''} />
      </Box>

      <Button onClick={updateSkill}>Save</Button>
      {' or '}
      <Link href={`/content/skills/${skillId}`}>cancel</Link>
    </main>
  )
}
