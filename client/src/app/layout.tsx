import '@mantine/core/styles.css'
import React from 'react'
import { ColorSchemeScript, MantineProvider } from '@mantine/core'
import { Notifications } from '@mantine/notifications'
import '@mantine/notifications/styles.css'
import { cssVariablesResolver, theme } from '@/theme'
import AuthenticatedLayout from '@/components/AuthenticatedLayout'
import './global.css'

export const metadata = {
  title: 'Samasya',
  description: 'Learn skills that build upon one another',
}

export default function RootLayout({ children }: { children: any }) {
  return (
    <html lang="en">
      <head>
        <link rel="shortcut icon" href="/icon.svg" sizes="any" />
        <meta
          name="viewport"
          content="minimum-scale=1, initial-scale=1, width=device-width, user-scalable=no"
        />
        <ColorSchemeScript defaultColorScheme="dark" />
      </head>
      <body>
        <MantineProvider
          cssVariablesResolver={cssVariablesResolver}
          defaultColorScheme="dark"
          theme={theme}
        >
          <Notifications />
          <AuthenticatedLayout>
            {children}
          </AuthenticatedLayout>
        </MantineProvider>
      </body>
    </html>
  )
}
