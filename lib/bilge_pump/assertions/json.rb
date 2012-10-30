module BilgePump
  module Assertions
    module Json
      def bilge_json_response
        bilge_json response.body
      end

      def bilge_json(text)
        ActiveSupport::JSON.decode(text)
      end

      def bilge_assert_index_response(collection_assign_name, items)
        bilge_assert_response :success

        models = bilge_json_response

        bilge_assert_includes models, bilge_json(items.first.to_json)
        bilge_assert_includes models, bilge_json(items.last.to_json)
      end

      def bilge_assert_new_response(item_assign_name)
        bilge_assert_response :success
      end

      CREATED = '201'
      def bilge_assert_create_response(options, expected_attrs, created_model)
        bilge_assert_response_code CREATED
        bilge_assert_equal bilge_json(created_model.to_json), bilge_json_response
        bilge_assert_model_attributes expected_attrs, created_model
      end

      def bilge_assert_edit_response(model, item_assign_name)
        bilge_assert_response :success
      end

      def bilge_assert_update_response(options, expected_attrs, model)
        bilge_assert_response_code CREATED
        bilge_assert_model_attributes expected_attrs, model
        bilge_assert_equal bilge_json(model.to_json), bilge_json_response
      end

      def bilge_assert_show_response(model, item_assign_name)
        bilge_assert_response :success
        bilge_assert_equal bilge_json(model.to_json), bilge_json_response
      end

      def bilge_assert_destroy_response(options, model)
        bilge_assert_response :success
        bilge_refute_existence model
      end
    end
  end
end

