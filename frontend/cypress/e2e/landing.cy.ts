describe('/', () => {
  it('mentions the name of the app', () => {
    cy.visit('/')
    cy.get('[data-testid="hero"]').should('contain', 'Samasya')
  })
})
