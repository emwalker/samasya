import { notifications } from '@mantine/notifications'
import { AppRouterInstance } from 'next/dist/shared/lib/app-router-context.shared-runtime'
import { ApiResponse } from '@/types'

export default function handleResponse(
  router: AppRouterInstance,
  response: ApiResponse<any>,
  route: string,
  title: string,
) {
  if (response.errors.length > 0) {
    response.errors.forEach(({ message }) => {
      notifications.show({
        title,
        color: 'red',
        position: 'top-center',
        message,
      })
    })
  } else {
    router.push(route)
  }
}
