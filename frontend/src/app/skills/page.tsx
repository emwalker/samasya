import styles from './page.module.css'

type Skill = {
  description: string,
}

type Response = {
  data: Skill[],
}

async function getData(): Promise<Response> {
  const res = await fetch('http://localhost:8000/api/v1/skills', { cache: 'no-store' })
 
  if (!res.ok) {
    throw new Error('Failed to fetch data')
  }
 
  return res.json()
}

export default async function Page() {
  const json = await getData()
  console.log('response', json)
  const skills = json.data || []

  return (
    <main>
      <h1 data-testid="page-name">Skills</h1>

      Available skills:
      {
        skills.map((skill) =>
          <div key={skill.description}>{ skill.description }</div>
        )
      }

      <p>
        <a href="/skills/new">Add a skill</a>
      </p>
    </main>
  )
}
