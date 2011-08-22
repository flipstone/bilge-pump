module BilgePump
  def self.Controller(options)
    module_with_options Controller, options
  end

  module Controller
    include ModelLocation

    def self.included(mod)
      mod.respond_to :html
      mod.extend ClassMethods
      mod.before_filter :find_scoping_models
      mod.bilge_pump_options.unsupported_actions(
        [:index, :show, :create, :update, :new, :edit, :destroy]
      ).each {|m| mod.send :undef_method, m}
    end

    def index
      respond_with_assign collection_assign_name, model_scope.scoped
    end

    def show
      respond_with_assign item_assign_name, find_model(model_scope, params[:id])
    end

    def create
      respond_with_assign item_assign_name, model_scope.create(params[model_param_name])
    end

    def update
      model = find_model model_scope, params[:id]
      model.update_attributes params[model_param_name]
      respond_with_assign item_assign_name, model
    end

    def new
      respond_with_assign item_assign_name, model_class.new
    end

    def edit
      respond_with_assign item_assign_name, find_model(model_scope,params[:id])
    end

    def destroy
      model = find_model(model_scope,params[:id])
      model.destroy
      respond_with_assign item_assign_name, model
    end

    protected

    def model_class
      self.class.model_class
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
      respond_with(*(@scoping_models + [model_or_models]))
    end

    def find_scoping_models
      @scoping_models = self.class.model_scope.inject([]) do |list, scope|
        list + [find_scoped_model(list.last, scope)]
      end
      self.class.model_scope.zip(@scoping_models.each) do |scope_name, model|
        instance_variable_set "@#{scope_name}", model
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

      find_model scope_for_find(scoping_model, model_class),
                 params["#{model_scope}_id"]
    end

    module ClassMethods
      include OptionsSupport

      def model_scope(scope = :not_passed)
        @model_scope ||= []
        @model_scope = scope unless scope == :not_passed
        @model_scope
      end

      def model_class(value_to_set = nil)
        @model_class = value_to_set if value_to_set
        @model_class || name.sub(/Controller\Z/, '').singularize.constantize
      end
    end
  end
end
