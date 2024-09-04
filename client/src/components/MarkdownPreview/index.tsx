'use client'

import React, { useEffect, useState } from 'react'
import { Card, TypographyStylesProvider } from '@mantine/core'
import { unified } from 'unified'
import remarkGfm from 'remark-gfm'
import remarkParse from 'remark-parse'
import remarkRehype from 'remark-rehype'
import rehypeStringify from 'rehype-stringify'

type Props = {
  markdown: string,
}

export default function MarkdownPreview({ markdown }: Props) {
  const [preview, setPreview] = useState<string>('')

  useEffect(() => {
    async function render() {
      const html = await unified()
        .use(remarkParse)
        .use(remarkGfm)
        .use(remarkRehype)
        .use(rehypeStringify)
        .process(markdown)
      setPreview(String(html))
    }
    render()
  }, [setPreview, markdown])

  return (
    <Card shadow="lg" mb={20}>
      <TypographyStylesProvider>
        <div
          // eslint-disable-next-line react/no-danger
          dangerouslySetInnerHTML={{ __html: preview }}
        />
      </TypographyStylesProvider>
    </Card>
  )
}
