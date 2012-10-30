module BilgePump
  module OptionsSupport
    def bilge_pump_options
      super
    rescue NoMethodError
      Options.new
    end
  end
end

