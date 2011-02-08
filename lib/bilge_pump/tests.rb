module BilgePump
  module Tests
    def bilge_assert_new_record(item_assign_name)
      assert assigns(item_assign_name).new_record?
    end

    def bilge_refute_existence(m)
      refute model_class.exists?(m.id)
    end

    def self.included(mod)
      mod.class_eval do
        def self.bilge_setup(*args,&block)
          setup(*args,&block)
        end

        def self.bilge_test(*args,&block)
          test(*args,&block)
        end

        alias_method :bilge_assert_response, :assert_response
        alias_method :bilge_assert_includes, :assert_includes
        alias_method :bilge_assert_equal, :assert_equal

        include AgnosticTests
      end
    end
  end
end
