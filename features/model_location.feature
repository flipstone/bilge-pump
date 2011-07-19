Feature: Model Location
  In order to control how models are retrieved from the database
  As a developer
  I want to be override default find behavior

  Scenario: Default behavior
    Given ModelLocation is included
    Given I have created a model
    When I locate the model using id
    Then I should find the model

  Scenario: Default behavior with scopes
    Given ModelLocation is included
    Given I have created a model
    And I locating models through a scope
    When I locate the model using id
    Then I should find the model

  Scenario: Default behavior with associations
    Given ModelLocation is included
    Given I have created a model
    And I locating models through an association
    When I locate the model using id
    Then I should find the model

  Scenario: Overridden behavior
    Given ModelLocation is included
    Given I have created a model
    And The model supports find_by_param
    When I locate the model using name
    Then I should find the model

  Scenario: Overridden behavior with scopes
    Given ModelLocation is included
    Given I have created a model
    And The model supports find_by_param
    When I locate the model using name
    Then I should find the model

  Scenario: Overridden behavior with associations
    Given ModelLocation is included
    Given I have created a model
    And The model supports find_by_param
    When I locate the model using name
    Then I should find the model

