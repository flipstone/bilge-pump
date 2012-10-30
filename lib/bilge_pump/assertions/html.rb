module BilgePump
  module Assertions
    module Html
      def bilge_assert_index_response(collection_assign_name, items)
        bilge_assert_response :success
        bilge_assert_includes assigns(collection_assign_name), items.first
        bilge_assert_includes assigns(collection_assign_name), items.last
      end

      def bilge_assert_new_response(item_assign_name)
        bilge_assert_response :success
        bilge_assert_new_record item_assign_name
      end

      def bilge_assert_create_response(options, expected_attrs, created_model)
        bilge_assert_response :redirect
        bilge_assert_model_attributes expected_attrs, created_model
      end

      def bilge_assert_edit_response(model, item_assign_name)
        bilge_assert_response :success
        bilge_assert_equal model, assigns(item_assign_name)
      end

      def bilge_assert_update_response(options, expected_attrs, model)
        bilge_assert_response :redirect
        bilge_assert_model_attributes expected_attrs, model
      end

      def bilge_assert_show_response(model, item_assign_name)
        bilge_assert_response :success
        bilge_assert_equal model, assigns(item_assign_name)
      end

      def bilge_assert_destroy_response(options, model)
        bilge_assert_response :redirect
        bilge_refute_existence model
      end
    end
  end
end
