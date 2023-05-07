describe('/', () => {
  it('mentions the name of the app', () => {
    cy.visit('/')
    cy.get('[data-testid="hero"]').should('contain', 'Samasya')
  })
})

// describe('/skills', () => {
//   beforeEach(() => {
//     cy.visit('/skills')
//   })

//   it('contains a listing of skills', () => {
//     cy.get('[data-testid="page-name"]').should('contain', 'Skills')
//   })
// })
