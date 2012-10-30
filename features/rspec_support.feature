Feature: RSpec Support
  In order to know my controller is working
  As a developer
  I want the to have working and robust specs to apply to the controller

  Scenario: Specs pass on simple controller (ActiveRecord)
    Given I am using ActiveRecord
    And I have included BilgePump::Controller in a controller
    And I have included BilgePump::Specs in an describe block
    When I run the specs
    Then They should all pass

  Scenario: Specs pass on json controller (ActiveRecord)
    Given I am using ActiveRecord
    And I have included BilgePump::Controller in a json controller
    And I have included BilgePump::Specs in an describe block for json format
    When I run the specs
    Then They should all pass

  Scenario: Specs pass on simple controller (MongoMapper)
    Given I am using MongoMapper
    And I have included BilgePump::Controller in a controller
    And I have included BilgePump::Specs in an describe block
    When I run the specs
    Then They should all pass

  Scenario: Specs pass on nested controller (ActiveRecord)
    Given I am using ActiveRecord
    And It has a belongs_to relationship
    And I have included BilgePump::Controller in a controller
    And I have declared model scope
    And I have included BilgePump::Specs in an describe block
    When I run the specs
    Then They should all pass

  Scenario: Specs pass on nested controller (MongoMapper)
    Given I am using MongoMapper
    And It has a belongs_to relationship
    And I have included BilgePump::Controller in a controller
    And I have declared model scope
    And I have included BilgePump::Specs in an describe block
    When I run the specs
    Then They should all pass

