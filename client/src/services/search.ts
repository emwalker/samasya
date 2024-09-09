import { ApiResponse } from "@/types"

export type SearchItemTypeEnum = 'task' | 'queue'

export type SearchItemType = {
  summary: string,
  id: string,
  type: SearchItemTypeEnum
}

export type SearchData = {
  results: SearchItemType[],
}

async function search(searchString: string): Promise<ApiResponse<SearchData>> {
  const q = encodeURIComponent(searchString)
  const response = await fetch(`http://localhost:8000/api/v1/search?q=${q}`, { method: 'GET' })
  return response.json()
}

export default { search }
