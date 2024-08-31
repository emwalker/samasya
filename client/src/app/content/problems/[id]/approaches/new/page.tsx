'use client'

import React from 'react'
import problemService from '@/services/problems'

type Params = {
  params: { id: string } | null
}

// eslint-disable-next-line @next/next/no-async-client-component
export default async function Page(params: Params) {
  const problemId = params?.params?.id
  if (problemId == null) {
    return <div>Loading ...</div>
  }

  const problem = (await problemService.fetch(problemId)).data
  if (problem == null) {
    return (
      <div>
        Problem not found:
        {problemId}
      </div>
    )
  }

  return (
    <main>
      Add approach form
    </main>
  )
}
