import React from 'react'
import Blankslate from '../Blankslate'

type InnerProps = {
  fallback: string | React.ReactElement,
  children: React.ReactElement[],
}

type ListOrProps = InnerProps & {
  title?: string | null,
}

const emptyChildren = (children: React.ReactElement[]) => React.Children.count(children) === 0

function Inner({ children, fallback }: InnerProps) {
  if (emptyChildren(children)) {
    return <Blankslate>{fallback}</Blankslate>
  }

  return children
}

export default function ListOr({ title = null, children, fallback }: ListOrProps) {
  return (
    <div>
      {title && (
        <h3>
          {title}
        </h3>
      )}
      <Inner fallback={fallback}>{children}</Inner>
    </div>
  )
}
