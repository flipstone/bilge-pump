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
            ms = (1..2).map { create_model }
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
            post :create, association_parameters.merge(
              model_param_name => Factory.attributes_for(model_factory_name,
                                                         attributes_for_create)
            )
            bilge_assert_response :redirect

            created_model = created_model_scope.last
            bilge_assert_model_attributes attributes_for_create, created_model
          end
        end

        options.testing :edit do
          bilge_test "edit works" do
            m = create_model
            get :edit, association_parameters.merge(id: m.to_param)
            bilge_assert_response :success
            bilge_assert_equal m, assigns(item_assign_name)
          end
        end

        options.testing :update do
          bilge_test "update works" do
            m = create_model
            post :update, association_parameters.merge(
              id: m.to_param, model_param_name => attributes_for_update
            )

            bilge_assert_response :redirect
            bilge_assert_model_attributes attributes_for_update, m.reload
          end
        end

        options.testing :show do
          bilge_test "show works" do
            m = create_model

            get :show, association_parameters.merge(id: m.to_param)
            bilge_assert_response :success
            bilge_assert_equal m, assigns(model_factory_name)
          end
        end

        options.testing :destroy do
          bilge_test "destroy works" do
            m = create_model

            delete :destroy, association_parameters.merge(id: m.to_param)
            bilge_assert_response :redirect
            bilge_refute_existence m
          end
        end
      end
    end

    module ClassMethods
      include OptionsSupport

      def model_class
        controller_class.name.sub(/Controller\Z/,'').singularize.constantize
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
    end

    (ClassMethods.instance_methods - [:model_scope]).each do |m|
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

    def all_scoped_models
      model_base_scope + @scoped_models
    end

    def create_scoped_models
      @scoped_models = model_scope.inject([]) do |list, model_name|
        m = Factory(model_name, association_attributes(list.last))
        instance_variable_set("@#{model_name}", m)
        list + [m]
      end
    end

    def create_model
      attributes_with_associations = all_scoped_models.inject(attributes_for_create) do |attributes, model|
        attributes.merge association_attributes(model)
      end

      Factory model_factory_name, attributes_with_associations
    end

    def association_parameters
      @scoped_models.inject({}) do |params, model|
        params.merge association_parameters_for(model)
      end
    end

    def association_parameters_for(model)
      reflection = model_class.reflect_on_association(model.class.model_name.singular.to_sym)
      { reflection.association_foreign_key => model.to_param }
    end

    def association_attributes(model)
      if model
        { model.class.model_name.element => model }
      else
        {}
      end
    end

    def attributes_for_create
      raise "#{self.class} must implement attributes_for_create for BilgePump"
    end

    def attributes_for_update
      raise "#{self.class} must implement attributes_for_create for BilgePump"
    end

    def bilge_assert_model_attributes(attributes_to_assert, model)
      names = attributes_to_assert.keys.map(&:to_s)
      attributes = Hash.new
      names.each { |n| attributes[n] = model.send n }
      
      bilge_assert_equal attributes_to_assert.stringify_keys, attributes
    end
  end
end
