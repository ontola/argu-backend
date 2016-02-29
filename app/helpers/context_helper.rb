module ContextHelper

  # Renders a to_parent breadcrumb block
  def  to_parent(parent = nil)
    if parent.present?
      if policy(parent).show?
        render partial: 'contextualize/to_parent',
               locals: {
                 parent: parent
               }
      end
    elsif current_context.parent_initialized?
      if policy(current_context.parent.model).show?
        render partial: 'contextualize/to_parent',
               locals: {
                 parent: current_context.parent.single_model
               }
      end
    end
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

  def horizontal_context_type_name(item, type)
    if type != 'argument'
     send("#{item.model_name.singular}_type", item)
    elsif item.pro
      t('arguments.form.side.pro')
    else
      t('arguments.form.side.con')
    end
  end

end
