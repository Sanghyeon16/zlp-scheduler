Feature: An Admin can open the current term
  As an administrator
  so that I can run the algorithm
  I want to be able to open the current term.
  
Background: log in as an admin
  Given the following terms exist:
  | name          |
  | Test Term     |
  And the active term is "Test Term"
  And the following cohorts exist:
  | name   |
  | Apple  |
  And "Apple" is in the current term
  And I am logged in as an admin
  
Scenario: View open term page
  When I click "Open"
  Then I should see the open semester page
    
Scenario: Cancel opening a term
  When I click "Open"
  And I click "Cancel"
  Then I should see the admin terms page
  
Scenario: Open term
  When I click "Open"
  And I fill in the open term form
  Then I should see the admin terms page
  And I should see "Term open dates updated."