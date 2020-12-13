Feature: An Admin can create a new term
  As an administrator
  so that I can run the algorithm
  I want to be able to create a new term.
  
Background: log in as an admin
  Given the following terms exist:
  | name            |
  | Test Term       |
  | Extra Test Term |
  | New Test Term   |
  And the active term is "Test Term"
  And the following cohorts exist:
  | name   |
  | Apple  |
  | Banana |
  And I am logged in as an admin
  
Scenario: View the create new term page
  When I click "New Term"
  Then I should see the new term page
  
Scenario: Cancel making a new term
  When I click "New Term"
  And I click "Cancel"
  Then I should see the admin terms page
  And I should see "Test Term"
  
Scenario: Create a new term
  When I click "New Term"
  And I fill in the new term form
  Then I should see the admin terms page
  And I should see "New Test Term"
  And I should see "Apple"
  And I should not see "Banana"
  
Scenario: Incomplete Form Redirects to Form Page
  When I click "New Term"
  And I fill in the new term form without cohorts
  Then I should see the new term page
  And I should see "Please select at least one cohort."
  And the term "New Test Term" should be selected
  