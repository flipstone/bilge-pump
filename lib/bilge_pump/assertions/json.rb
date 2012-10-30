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
        response.should be_success

        models = bilge_json_response

        models.should include bilge_json(items.first.to_json)
        models.should include bilge_json(items.last.to_json)
      end

      def bilge_assert_new_response(item_assign_name)
        response.should be_success
      end

      CREATED = '201'
      def bilge_assert_create_response(options, expected_attrs, created_model)
        response.code.should == CREATED
        bilge_json_response.should == bilge_json(created_model.to_json)
        bilge_assert_model_attributes expected_attrs, created_model
      end

      def bilge_assert_edit_response(model, item_assign_name)
        response.should be_success
      end

      def bilge_assert_update_response(options, expected_attrs, model)
        response.code.should == CREATED
        bilge_assert_model_attributes expected_attrs, model
        bilge_json_response.should == bilge_json(model.to_json)
      end

      def bilge_assert_show_response(model, item_assign_name)
        response.should be_success
        bilge_json_response.should == bilge_json(model.to_json)
      end

      def bilge_assert_destroy_response(options, model)
        response.should be_success
        model.class.find_by_id(model.id).should be_nil
      end
    end
  end
end

