require 'rspec/expectations'
require 'tempfile'

Before do
  @source_code = <<-end_code
    $LOAD_PATH << "#{File.expand_path(File.join(File.dirname(__FILE__), %w(.. .. lib)))}"

    require 'rack'
    require 'rails'
    require 'action_controller'
    require 'action_mailer' # to satisfy RSpec::Rails::MailerExampleGroup
    require 'bilge-pump'
    require 'rspec/rails'
    require 'factory_girl'

    module BilgePumpTestApp
      class Application < Rails::Application
      end
    end

    BilgePumpTestApp::Application.routes.draw do
      resources :foos
      resources :bars do
        resources :foos
      end
    end

    Factory.define :foo do |f|
      f.name "Foo"
    end

    Factory.define :bar do |f|
      f.name "foo"
    end

  end_code
end

Given /^I am using ActiveRecord$/ do
  @source_code << <<-end_code
    require 'active_record'

    ActiveRecord::Base.establish_connection({
      adapter: 'sqlite3',
      database: '#{Tempfile.new('bilge-pump-feature-db').path}'
    })

    ActiveRecord::Base.connection.execute <<-end_ddl
      CREATE TABLE bars(id INTEGER PRIMARY KEY ASC, name VARCHAR(255))
    end_ddl

    ActiveRecord::Base.connection.execute <<-end_ddl
      CREATE TABLE foos(id INTEGER PRIMARY KEY ASC, name VARCHAR(255), bar_id INTEGER)
    end_ddl

    class Foo < ActiveRecord::Base; end
    class Bar < ActiveRecord::Base; end

  end_code
end

Given /^I am using MongoMapper$/ do
  @source_code << <<-end_code
    require 'mongo_mapper'
    MongoMapper.database = 'bilge-pump-feature-db'
    MongoMapper.database.connection.drop_database 'bilge-pump-feature-db'

    MongoMapper::Document.plugin BilgePump::MongoMapper::Document

    class Bar
      include MongoMapper::Document

      key :name, String
    end

    class Foo
      include MongoMapper::Document

      key :name, String
      key :bar_id, ObjectId
    end
  end_code
end

Given /^It has a belongs_to relationship$/ do
  @source_code << <<-end_code
    Foo.class_eval { belongs_to :bar }
    Bar.class_eval { has_many :foos }
  end_code
end


Given /^I have included BilgePump::Controller in a controller$/ do
  @source_code << <<-end_code
    class FoosController < ActionController::Base
      include Rails.application.routes.url_helpers
      self.view_paths = "#{File.expand_path(File.join(File.dirname(__FILE__), %w(../support/empty_crud_views)))}"
      include BilgePump::Controller
    end
  end_code
end

Given /^I have included BilgePump::Controller in a json controller$/ do
  @source_code << <<-end_code
    class FoosController < ActionController::Base
      include Rails.application.routes.url_helpers
      respond_to :json
      include BilgePump::Controller
    end
  end_code
end

Given /^I have declared model scope$/ do
  @model_scope = "[:bar]"
  @source_code << <<-end_code
    FoosController.class_eval do
      model_scope #{@model_scope}
    end
  end_code
end


Given /^I have included BilgePump::Specs in an describe block$/ do
  @source_code << <<-end_code
    describe FoosController, type: :controller do
      include BilgePump::Specs
      #{"model_scope #{@model_scope}" if @model_scope}

      def attributes_for_create
        { name: "Bar" }
      end

      def attributes_for_update
        { name: "Baz" }
      end
    end
  end_code
end

Given /^I have included BilgePump::Specs in an describe block for json format$/ do
  @source_code << <<-end_code
    describe FoosController, type: :controller do
      include BilgePump::Specs format: :json

      def attributes_for_create
        { name: "Bar" }
      end

      def attributes_for_update
        { name: "Baz" }
      end
    end
  end_code
end

Given /^the model supports only find_by_param$/ do
  @source_code << <<-end_code
    Foo.singleton_class.class_eval do
      alias_method :find_by_param, :find
      private :find
    end
  end_code
end

When /^I run the specs$/ do
  path = nil
  Tempfile.open 'run_the_specs.rb' do |f|
    f.write @source_code
    path = f.path
  end
  @output = `BUNDLE_GEMFILE='' BUNDLE_BIN_PATH='' RUBYOPT='' bundle exec rspec #{path} 2>&1`
  @result = $?
end

Then /^They should all pass$/ do
  @result.should be_success, @output
end

