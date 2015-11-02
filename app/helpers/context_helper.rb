module ContextHelper

  # Renders a to_parent breadcrumb block
  def  to_parent
    render partial: 'contextualize/to_parent' if current_context.parent_initialized?
  end

  # Generates a link with the current context kept
  def contextual_link_to(name = nil, options = nil, html_options = nil, &block)
    # @TODO: Fix the context parsing system (https://trello.com/c/KTJZJ4Bp/312-context-system-refactor)
    # @note: Disabled until above is done
    # if block_given?
    #   name = merge_query_parameter(name, current_context.to_query) if name.class == String
    # else
    #   options = merge_query_parameter(options, current_context.to_query) if options.class == String
    # end
    link_to name, options, html_options, &block
  end

  def forum_from_scope_or_model(current_scope, model)
    if model.respond_to? :uses_alternative_names
      model
    else
      current_scope.model.try(:forum) || current_scope.model || model.forum
    end
  end

end
