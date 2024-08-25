import React from 'react'

type InnerProps = {
  fallback: string | React.ReactElement,
  children: React.ReactElement[],
}

type ListOrProps = InnerProps & {
  title: string,
}

const emptyChildren = (children: React.ReactElement[]) => React.Children.count(children) === 0

function Inner({ children, fallback }: InnerProps) {
  if (emptyChildren(children)) {
    return <div>{fallback}</div>
  }

  return children
}

export default function ListOr({ title, children, fallback }: ListOrProps) {
  return (
    <div>
      <h3>
        {title}
      </h3>
      <Inner fallback={fallback}>{children}</Inner>
    </div>
  )
}
