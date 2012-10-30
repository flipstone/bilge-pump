module BilgePump
  module Specs
    module ClassMethods
      include OptionsSupport

      def model_class(value_to_set = nil)
        @model_class = value_to_set if value_to_set
        @model_class || controller_class.name.sub(/Controller\Z/,'').singularize.constantize
      end

      def singular_model_name
        model_class.model_name.singular
      end
      alias_method :model_factory_name, :singular_model_name
      alias_method :item_assign_name, :singular_model_name
      alias_method :model_param_name, :singular_model_name

      def plural_model_name
        model_class.model_name.plural
      end
      alias_method :collection_assign_name, :plural_model_name

      def model_scope(scope)
        class_eval do
          define_method(:model_scope) { scope }
        end
      end

      def model_factories
        @model_factories ||= {}
      end

      def model_factory(name, &block)
        model_factories[name.to_s] = block
      end
    end
  end
end

