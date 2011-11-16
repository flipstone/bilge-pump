module BilgePump
  module AgnosticTests
    def self.included(mod)
      mod.extend ClassMethods
      options = mod.bilge_pump_options

      mod.class_eval do
        bilge_setup do
          create_scoped_models
        end

        options.testing :index do
          bilge_test "index works" do
            ms = (1..2).map { create_model(:index) }
            get :index, association_parameters
            bilge_assert_response :success
            bilge_assert_includes assigns(collection_assign_name), ms.first
            bilge_assert_includes assigns(collection_assign_name), ms.last
          end
        end

        options.testing :new do
          bilge_test "new works" do
            get :new, association_parameters
            bilge_assert_response :success
            bilge_assert_new_record item_assign_name
          end
        end

        options.testing :create do
          bilge_test "create works" do
            original_items = created_model_scope.all

            post :create, association_parameters.merge(
              model_param_name => parameters_for_create
            )
            bilge_assert_response :redirect

            new_items = created_model_scope.all

            created_model = (new_items - original_items).first
            bilge_assert_model_attributes attributes_for_create, created_model
          end
        end

        options.testing :edit do
          bilge_test "edit works" do
            m = create_model(:edit)
            get :edit, association_parameters.merge(id: m.to_param)
            bilge_assert_response :success
            bilge_assert_equal m, assigns(item_assign_name)
          end
        end

        options.testing :update do
          bilge_test "update works" do
            m = create_model(:create)
            post :update, association_parameters.merge(
              id: m.to_param, model_param_name => parameters_for_update
            )

            bilge_assert_response :redirect
            bilge_assert_model_attributes attributes_for_update, m.reload
          end
        end

        options.testing :show do
          bilge_test "show works" do
            m = create_model(:show)

            get :show, association_parameters.merge(id: m.to_param)
            bilge_assert_response :success
            bilge_assert_equal m, assigns(model_factory_name)
          end
        end

        options.testing :destroy do
          bilge_test "destroy works" do
            m = create_model(:destroy)

            delete :destroy, association_parameters.merge(id: m.to_param)
            bilge_assert_response :redirect
            bilge_refute_existence m
          end
        end
      end
    end

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
      attributes_with_associations = @scoped_models.zip(model_scope).inject(attributes_for_action(action)) do |attributes, (model, options)|
        attributes.merge association_attributes(model, options)
      end

      bilge_create model_factory_name, attributes_with_associations
    end

    def bilge_create(name, attributes)
      if factory = model_factories[name.to_s]
        instance_exec attributes, &factory
      else
        Factory name, attributes
      end
    end

    def attributes_for_action(action)
      if respond_to?("attributes_for_#{action}")
        send "attributes_for_#{action}"
      else
        attributes_for_create
      end
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
      Factory.attributes_for model_factory_name, attributes_for_create
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

      bilge_assert_equal attributes_to_assert.stringify_keys, attributes
    end
  end
end
