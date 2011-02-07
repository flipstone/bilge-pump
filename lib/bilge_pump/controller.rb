module BilgePump
  module Controller
    def self.included(mod)
      mod.respond_to :html
      mod.extend ClassMethods
      mod.before_filter :find_scoping_models
    end

    def index
      respond_with_assign collection_assign_name, model_scope.scoped
    end

    def show
      respond_with_assign item_assign_name, model_scope.find(params[:id])
    end

    def create
      respond_with_assign item_assign_name, model_scope.create(params[model_param_name])
    end

    def update
      respond_with_assign item_assign_name, model_scope.update(params[:id], params[model_param_name])
    end

    def new
      respond_with_assign item_assign_name, model_class.new
    end

    def edit
      respond_with_assign item_assign_name, model_scope.find(params[:id])
    end

    def destroy
      respond_with_assign item_assign_name, model_scope.find(params[:id]).destroy
    end

    protected

    def model_class
      self.class.name.sub(/Controller\Z/, '').singularize.constantize
    end

    def model_scope
      scope_for_find(@scoping_models.last, model_class)
    end

    def model_param_name
      model_class.model_name.singular
    end

    def collection_assign_name
      model_class.model_name.plural
    end

    def item_assign_name
      model_class.model_name.singular
    end

    def respond_with_assign(assignment, model_or_models)
      instance_variable_set "@#{assignment}", model_or_models
      respond_with(@scoping_models + [model_or_models])
    end

    def find_scoping_models
      @scoping_models = self.class.model_scope.inject([]) do |list, scope|
        list + [find_scoped_model(list.last, scope)]
      end
      @scoping_models.each do |model|
        instance_variable_set "@#{model.class.model_name.singular}", model
      end
    end

    def scope_for_find(scoping_model, model_class)
      if scoping_model
        scoping_model.send(model_class.model_name.plural)
      else
        model_class
      end
    end

    def find_scoped_model(scoping_model, model_scope)
      model_class = model_scope.to_s.classify.constantize
      scope_for_find(scoping_model, model_class).find params["#{model_scope}_id"]
    end

    module ClassMethods
      def model_scope(scope = :not_passed)
        @model_scope ||= []
        @model_scope = scope unless scope == :not_passed
        @model_scope
      end
    end
  end
end
