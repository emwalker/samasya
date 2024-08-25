import { notifications } from '@mantine/notifications'
import { AppRouterInstance } from 'next/dist/shared/lib/app-router-context.shared-runtime'
import { ApiResponse } from '@/types'

function handleError(
  response: ApiResponse<any>,
  title: string,
) {
  response.errors.forEach(({ message }) => {
    notifications.show({
      title,
      color: 'red',
      position: 'top-center',
      message,
    })
  })
}

function handleResponse(
  router: AppRouterInstance,
  response: ApiResponse<any>,
  route: string,
  title: string,
) {
  if (response.errors.length > 0) {
    handleError(response, title)
  } else {
    router.push(route)
  }
}

export default handleResponse
export { handleError }
