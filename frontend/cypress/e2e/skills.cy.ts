
describe('/skills', () => {
  beforeEach(() => {
    cy.visit('/skills')
  })

  it('contains a listing of skills', () => {
    cy.get('[data-testid="page-name"]').should('contain', 'Skills')
  })
})
