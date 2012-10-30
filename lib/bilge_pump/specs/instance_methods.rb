module BilgePump
  module Specs
    module InstanceMethods
      (ClassMethods.instance_methods - [:model_scope, :model_factory]).each do |m|
        class_eval %{
          def #{m}(*args)
            self.class.#{m} *args
          end
        }
      end

      def created_model_scope
        model_class
      end

      def model_scope
        []
      end

      def model_base_scope
        []
      end

      def create_scoped_models
        @scoped_models = model_scope.inject([]) do |list, options|
          model_name = options.is_a?(Hash) ? options.keys.first : options

          m = bilge_create model_name, association_attributes(list.last)
          instance_variable_set("@#{model_name}", m)
          list + [m]
        end
      end

      def create_model(action = :create)
        parent = @scoped_models.last
        options = model_scope.last
        assoc_attrs = parent ? association_attributes(parent, options) : {}
        attrs = attributes_for_action(action)

        bilge_create model_factory_name, attrs.merge(assoc_attrs)
      end

      def bilge_create(name, attributes)
        if factory = model_factories[name.to_s]
          instance_exec attributes, &factory
        else
          ::BilgePump::Factory.create name, attributes
        end
      end

      def attributes_for_action(action)
        if respond_to?("attributes_for_#{action}")
          send "attributes_for_#{action}"
        else
          attributes_for_create
        end
      end

      def base_parameters
        association_parameters.merge(:format => bilge_pump_options.format.to_s)
      end

      def association_parameters
        @scoped_models.inject({}) do |params, model|
          params.merge association_parameters_for(model)
        end
      end

      def association_parameters_for(model)
        reflection = model_class.reflect_on_association(model.class.model_name.singular.to_sym)
        if reflection
          { reflection.association_foreign_key => model.to_param }
        else
          { "#{model.class.model_name.singular}_id" => model.to_param }
        end
      end

      def association_attributes(model, options = {})
        if model
          model_name_from_options = options.is_a?(Hash) ? options.values.first : nil
          model_name = model_name_from_options || model.class.model_name.element

          {  model_name => model }
        else
          {}
        end
      end

      def parameters_for_create
        BilgePump::Factory.attributes_for model_factory_name, attributes_for_create
      end

      def attributes_for_create
        raise "#{self.class} must implement attributes_for_create for BilgePump"
      end

      def parameters_for_update
        attributes_for_update
      end

      def attributes_for_update
        raise "#{self.class} must implement attributes_for_update for BilgePump"
      end

      def bilge_assert_model_attributes(attributes_to_assert, model)
        names = attributes_to_assert.keys.map(&:to_s)
        attributes = Hash.new
        names.each { |n| attributes[n] = model.send n }

        attributes_to_assert.stringify_keys.should == attributes
      end
    end
  end
end
