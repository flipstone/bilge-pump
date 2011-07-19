require 'rspec/expectations'
require 'tempfile'

Before do
  @source_code = <<-end_code
    gem 'rack', '~> 1.2'
    gem 'rails', '3.0.4'
    gem 'rspec-rails', '~> 2.4'
    gem 'factory_girl', '~> 1.3'
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
    end

    ActiveRecord::Base.establish_connection({
      adapter: 'sqlite3',
      database: '#{Tempfile.new('bilge-pump-feature-db').path}'
    })

    ActiveRecord::Base.connection.execute <<-end_ddl
      CREATE TABLE foos(id INTEGER PRIMARY KEY ASC, name VARCHAR(255))
    end_ddl

    class Foo < ActiveRecord::Base; end

    Factory.define :foo do |f|
      f.name "Foo"
    end

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

Given /^I have included BilgePump::Specs in an describe block$/ do
  @source_code << <<-end_code
    describe FoosController, type: :controller do
      include BilgePump::Specs

      def attributes_for_create
        { name: "Bar" }
      end

      def attributes_for_update
        { name: "Baz" }
      end
    end
  end_code
end

When /^I run the specs$/ do
  path = nil
  Tempfile.open 'run_the_specs.rb' do |f|
    f.write @source_code
    path = f.path
  end
  @output = `BUNDLE_GEMFILE='' BUNDLE_BIN_PATH='' RUBYOPT='' rspec #{path} 2>&1`
  @result = $?
end

Then /^They should all pass$/ do
  @result.should be_success, @output
end

