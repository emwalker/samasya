'use client'

import React from 'react'

type Problem = {
  description: string,
  skillIds: string[]
}

type Response = {
  data: Problem | null
}

async function getData({ id }: { id: string }): Promise<Response> {
  const res = await fetch(`http://localhost:8000/api/v1/problems/${id}`, { cache: 'no-store' })

  if (!res.ok) {
    return Promise.resolve({ data: null })
  }

  return res.json()
}

type Params = {
  params?: { id: string } | null
}

export default async function Page(params: Params) {
  if (params?.params == null) {
    return null
  }

  const { id } = params.params
  const problem = (await getData({ id })).data

  return (
    <main>
      <div>
        <h1>
          Problem:
          { problem?.description || 'not found' }
        </h1>
      </div>
    </main>
  )
}
