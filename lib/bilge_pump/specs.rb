require_relative 'specs/class_methods'
require_relative 'specs/instance_methods'

module BilgePump
  module Specs
    def self.included(mod)
      mod.class_eval do
        render_views

        extend ClassMethods
        include InstanceMethods
        options = bilge_pump_options
        include options.format_assertions

        before :each do
          request.accept = options.mime_type
          create_scoped_models
        end

        options.testing :new do
          it "new works" do
            get :new, base_parameters
            bilge_assert_new_response item_assign_name
          end
        end

        options.testing :create do
          it "create works" do
            original_items = created_model_scope.all.to_a

            post :create, base_parameters.merge(
              model_param_name => parameters_for_create
            )

            new_items = created_model_scope.all.to_a

            created_model = (new_items - original_items).first

            bilge_assert_create_response options,
                                         attributes_for_create,
                                             created_model
          end
        end

        options.testing :edit do
          it "edit works" do
            m = create_model(:edit)
            get :edit, base_parameters.merge(id: m.to_param)
            bilge_assert_edit_response m, item_assign_name
          end
        end

        options.testing :update do
          it "update works" do
            m = create_model(:create)
            post :update, base_parameters.merge(
              id: m.to_param, model_param_name => parameters_for_update
            )

            bilge_assert_update_response options,
                                         attributes_for_update,
                                         m.reload
          end
        end

        options.testing :show do
          it "show works" do
            m = create_model(:show)

            get :show, base_parameters.merge(id: m.to_param)

            bilge_assert_show_response m, item_assign_name
          end
        end

        options.testing :destroy do
          it "destroy works" do
            m = create_model(:destroy)

            delete :destroy, base_parameters.merge(id: m.to_param)

            bilge_assert_destroy_response options, m
          end
        end
      end
    end
  end
end
