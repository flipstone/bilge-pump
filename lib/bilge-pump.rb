module BilgePump
  autoload :Controller, 'bilge_pump/controller'
  autoload :Factory, 'bilge_pump/factory'
  autoload :Options, 'bilge_pump/options'
  autoload :OptionsSupport, 'bilge_pump/options_support'
  autoload :ModelLocation, 'bilge_pump/model_location'
  autoload :MongoMapper, 'bilge_pump/mongo_mapper'
  autoload :Specs, 'bilge_pump/specs'

  module Assertions
    autoload :Html, 'bilge_pump/assertions/html'
    autoload :Json, 'bilge_pump/assertions/json'
  end

  def self.Controller(options)
    module_with_options Controller, options
  end

  def self.Specs(options)
    module_with_options Specs, options
  end
end


