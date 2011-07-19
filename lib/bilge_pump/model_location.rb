module ModelLocation
  def find_model(scope, selector)
    if scope.respond_to?(:find_by_param)
      scope.find_by_param selector
    else
      scope.find selector
    end
  end
end
