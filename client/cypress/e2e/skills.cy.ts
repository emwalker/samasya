
describe('/content/skills', () => {
  beforeEach(() => {
    cy.visit('/content/skills')
  })

  it('contains a listing of skills', () => {
    cy.get('[data-testid="page-name"]').should('contain', 'Skills')
  })
})
