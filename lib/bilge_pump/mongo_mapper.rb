module BilgePump
  module MongoMapper
    module Document
      extend ActiveSupport::Concern

      included do
        scope :scoped
      end

      module ClassMethods
        def reflect_on_association(name)
          if assoc = associations[name]
            AssociationAdapter.new assoc
          end
        end
      end

      class AssociationAdapter < Struct.new(:association)
        def association_foreign_key
          association.foreign_key
        end
      end
    end
  end
end
