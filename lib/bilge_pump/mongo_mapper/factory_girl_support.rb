module BilgePump
  module MongoMapper
    module FactoryExtensions
      extend ActiveSupport::Concern

      module ClassMethods
        def embedded(name, overrides = {})
          factory_by_name(name).run(Proxy::Embedded, overrides)
        end
      end

      module Proxy
        class Embedded < Factory::Proxy::Create
          def set(attribute, value)
            if !@instance.respond_to?("#{attribute}=")
              collection_options = value.class.associations.values.select do |assoc|
                assoc.embeddable? && assoc.class_name == @instance.class.name
              end

              case collection_options.size
              when 1
                value.send(collection_options.first.name).push @instance
              when 0
                raise "Unable to find collection to embed #{@instance} into #{value}"
              else
                raise "Found too many collections to embed #{@instance} into #{value}: #{collection_options.map(&:name)}"
              end
            else
              super
            end
          end
        end
      end
    end
  end
end

Factory.send :include, BilgePump::MongoMapper::FactoryExtensions
