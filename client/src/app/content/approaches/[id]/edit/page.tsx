'use client'

import React, {
  ChangeEvent,
  useCallback, useEffect, useState,
} from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { ApproachType } from '@/types'
import approachService, { FetchData } from '@/services/approaches'
import { Box } from '@mantine/core'
import { handleError } from '@/app/handleResponse'
import styles from './page.module.css'

type SaveButtonProps = {
  disabled: boolean,
  approachId: string,
  name: string,
}

function SaveButton({
  disabled, approachId, name,
}: SaveButtonProps) {
  const router = useRouter()

  const onClick = useCallback(async () => {
    const response = await approachService.update(approachId, { name })

    if (response.ok) {
      router.push(`/content/approaches/${approachId}`)
    }
  }, [approachId, name, router])

  return (
    <button disabled={disabled} onClick={onClick} type="submit">Update</button>
  )
}

type EditFormProps = {
  approach: ApproachType,
}

function EditForm({ approach }: EditFormProps) {
  const {
    id: approachId,
    summary: initialSummary,
  } = approach
  const [name, setSummary] = useState(initialSummary)

  const nameOnChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => setSummary(event.target.value),
    [setSummary],
  )

  return (
    <div className={styles.editForm}>
      <p>
        {approach.summary}
      </p>

      <div>
        <input
          type="text"
          size={100}
          value={name}
          placeholder="Name of approach"
          onChange={nameOnChange}
        />
      </div>

      <p>
        <SaveButton
          disabled={false}
          approachId={approachId}
          name={name}
        />
        {' or '}
        <Link href={`/content/approaches/${approachId}`}>cancel</Link>
      </p>
    </div>
  )
}

type Props = {
  params?: { id: string } | null
}

export default function Page(props: Props) {
  const [fetchData, setFetchData] = useState<FetchData | null>(null)
  const approachId = props?.params?.id || null

  useEffect(() => {
    async function loadData() {
      if (approachId == null) return
      const response = await approachService.fetch(approachId)
      handleError(response, 'Failed to fetch approach')
      setFetchData(response?.data || null)
    }
    loadData()
  }, [approachId])

  const approach = fetchData?.approach || null

  return (
    <Box>
      <h1>
        Update approach
      </h1>

      {approach && <EditForm approach={approach} />}
    </Box>
  )
}
