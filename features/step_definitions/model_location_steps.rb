require_relative '../../lib/bilge-pump'
require 'tempfile'
require 'active_record'

Before do
  ActiveRecord::Base.establish_connection({
    adapter: "sqlite3",
    database: Tempfile.new('bilge-pump-feature-db').path
  })

  ActiveRecord::Base.connection.execute <<-end_ddl
    CREATE TABLE bars(id INTEGER PRIMARY KEY ASC)
  end_ddl

  ActiveRecord::Base.connection.execute <<-end_ddl
    CREATE TABLE foos(id INTEGER PRIMARY KEY ASC, name VARCHAR(255), bar_id INTEGER)
  end_ddl
end

class Bar < ActiveRecord::Base
  has_many :foos
end

class Foo < ActiveRecord::Base
  belongs_to :bar
  scope :a_scope, order(:name)
end

Given /^ModelLocation is included$/ do
  extend ModelLocation
end

Given /^I have created a model$/ do
  Foo.singleton_class.class_eval do
    remove_method :find_by_param if methods.include?(:find_by_param)
  end
  @model = Foo.create name: "bar"
  @scope = Foo
end

Given /^I locating models through a scope$/ do
  @scope = @scope.a_scope
end

Given /^I locating models through an association$/ do
  parent = Bar.create
  parent.foos << @model

  @scope = parent.foos
end

Given /^The model supports find_by_param$/ do
  Foo.singleton_class.class_eval do
    def find_by_param(param)
      where(name: param).first
    end
  end
end

When /^I locate the model using (\S*)$/ do |attr|
  @found_model = find_model @scope, @model.send(attr)
end

Then /^I should find the model$/ do
  @found_model.should == @model
end

