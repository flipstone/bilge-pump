module BilgePump
  module Specs
    def self.included(mod)
      mod.extend ClassMethods
      mod.class_eval do
        describe "cruddiness" do
          render_views

          before(:each) { create_scoped_models }

          it "index works" do
            ms = (1..2).map { create_model }
            get :index, association_parameters
            response.should be_success
            assigns(collection_assign_name).should be_member(ms.first)
            assigns(collection_assign_name).should be_member(ms.last)
          end

          it "new works" do
            get :new, association_parameters
            response.should be_success
            assigns(item_assign_name).should be_new_record
          end

          it "create works" do
            post :create, association_parameters.merge(
              model_param_name => Factory.attributes_for(model_factory_name, attributes_for_create)
            )
            response.should be_redirect

            created_model = created_model_scope.order('id').last
            assert_model_attributes attributes_for_create, created_model
          end

          it "edit works" do
            m = create_model
            get :edit, association_parameters.merge(id: m.to_param)
            response.should be_success
            assigns(item_assign_name).should == m
          end

          it "update works" do
            m = create_model
            post :update, association_parameters.merge(
              id: m.to_param,
              model_param_name => attributes_for_update
            )

            response.should be_redirect
            assert_model_attributes attributes_for_update, m.reload
          end

          it "show works" do
            m = create_model

            get :show, association_parameters.merge(id: m.to_param)
            response.should be_success
            assigns(model_factory_name).should == m
          end

          it "destroy works" do
            m = create_model

            delete :destroy, association_parameters.merge(id: m.to_param)
            response.should be_redirect
            model_class.should_not be_exists(m.id)
          end
        end
      end
    end

    module ClassMethods
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

    ClassMethods.instance_methods.each do |m|
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

    def create_scoped_models
      @scoped_models = model_scope.inject([]) do |list, model_name|
        list + [Factory(model_name, association_attributes(list.last))]
      end
    end

    def create_model
      attributes_with_associations = @scoped_models.inject(attributes_for_create) do |attributes, model|
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

    def assert_model_attributes(attributes_to_assert, model)
      names = attributes_to_assert.keys.map(&:to_s)
      attributes = model.attributes.select { |k,v| names.include?(k) }

      attributes.should == attributes_to_assert.stringify_keys
    end

    def attributes_for_create
      raise "#{self.class} must implement attributes_for_create for CruddyTests"
    end
  end
end
