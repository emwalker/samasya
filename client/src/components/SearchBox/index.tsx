import React, { ChangeEvent, useCallback, useState } from 'react'
import { useSearchParams } from 'next/navigation'
import { TextInput } from '@mantine/core'
import { useRouter } from 'next/navigation'
import classes from './index.module.css'

export default function SearchBox() {
  const router = useRouter()
  const params = useSearchParams()
  const searchParam = params.get('q') || ''
  const [nextSearch, setNextSearch] = useState<string | null>(searchParam)

  const onSearch = useCallback((event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Enter') {
      const q = encodeURIComponent(nextSearch || '')
      router.push(`/search?q=${q}`)
    }
  }, [nextSearch, router])

  const setSearch = useCallback((event: ChangeEvent<HTMLInputElement>) => {
    setNextSearch(event.target.value || '')
  }, [setNextSearch])

  return (
    <TextInput
      className={classes.searchBox}
      defaultValue={nextSearch || ''}
      placeholder="Search"
      onKeyDown={onSearch}
      onChange={setSearch}
      radius="xl"
    />
  )
}