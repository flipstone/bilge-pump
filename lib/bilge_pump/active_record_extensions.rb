require 'active_record'

module BilgePump
  module FindByParam
    def find_by_param(param)
      find param
    end
  end
end

ActiveRecord::Base.send :extend, BilgePump::FindByParam
