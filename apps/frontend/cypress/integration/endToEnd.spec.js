describe("MERN application smoke flow", () => {
  const employeeName = `Employee-${Date.now()}`;

  it("shows frontend navigation and API health", () => {
    cy.visit("/");
    cy.contains("API Status").should("exist");
    cy.contains('"message":"OK"').should("exist");
    cy.contains("Create Record").should("exist");
    cy.screenshot("app-home");
  });

  it("creates and deletes a record through the UI", () => {
    cy.visit("/create");
    cy.get("#name").type(employeeName);
    cy.get("#position").type("Platform Engineer");
    cy.get("#positionIntern").click({ force: true });
    cy.contains("Create person").click({ force: true });
    cy.location("pathname").should("eq", "/");

    cy.visit("/records");
    cy.contains("td", employeeName, { timeout: 10000 }).should("exist");
    cy.screenshot("record-list");
    cy.contains("tr", employeeName).contains("Delete").click({ force: true });
    cy.contains("td", employeeName).should("not.exist");
  });
});
