module BilgePump
  module Assertions
    module Html
      def bilge_assert_index_response(collection_assign_name, items)
        response.should be_success
        assigns(collection_assign_name).should include items.first
        assigns(collection_assign_name).should include items.last
      end

      def bilge_assert_new_response(item_assign_name)
        response.should be_success
        assigns(item_assign_name).should be_new_record
      end

      def bilge_assert_create_response(options, expected_attrs, created_model)
        response.should be_redirect
        bilge_assert_model_attributes expected_attrs, created_model
      end

      def bilge_assert_edit_response(model, item_assign_name)
        response.should be_success
        assigns(item_assign_name).should == model
      end

      def bilge_assert_update_response(options, expected_attrs, model)
        response.should be_redirect
        bilge_assert_model_attributes expected_attrs, model
      end

      def bilge_assert_show_response(model, item_assign_name)
        response.should be_success
        assigns(item_assign_name).should == model
      end

      def bilge_assert_destroy_response(options, model)
        response.should be_redirect
        model.class.find_by_id(model.id).should be_nil
      end
    end
  end
end
