module BilgePump
  module Factory
    def self.factory
      if defined? ::Factory
        ::Factory
      else
        ::FactoryGirl
      end
    end

    def self.create(name, attributes)
      factory.create name, attributes
    end

    def self.attributes_for(name, attributes)
      factory.attributes_for name, attributes
    end
  end
end
