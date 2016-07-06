module ContextHelper
  # Renders a to_parent breadcrumb block
  def  to_parent(parent = nil)
    if parent.blank?
      parent =
        if authenticated_resource.edge.owner_type == 'Forum'
          authenticated_resource.edge
        else
          authenticated_resource.edge.parent.owner
        end
    end
    if policy(parent).show?
      render partial: 'contextualize/to_parent',
             locals: {
               parent: parent
             }
    end
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
