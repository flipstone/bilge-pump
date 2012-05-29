module BilgePump
  class Options
    def initialize(o = {})
      @o = o
    end

    def testing(action)
      if (@o[:only] || []).include?(action) || @o[:only].nil?
        yield
      end
    end

    def unsupported_actions(actions)
      if @o[:only]
        actions - @o[:only]
      else
        []
      end
    end

    def format
      @o[:format] || :html
    end

    def redirecting_format?
      format == :html
    end

    def mime_type
      Mime::Type.lookup_by_extension(format).to_s
    end
  end

  module OptionsSupport
    def bilge_pump_options
      super
    rescue NoMethodError
      Options.new
    end
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
