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

  def self.module_with_options(mod_with_options, options)
    Module.new do
      @options = options
      @mod_with_options = mod_with_options

      def self.included(mod)
        mod.singleton_class.class_eval { attr_accessor :bilge_pump_options }
        mod.bilge_pump_options = Options.new(@options)
        mod.send :include, @mod_with_options
      end
    end
  end
end


