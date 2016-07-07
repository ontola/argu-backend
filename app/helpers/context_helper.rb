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
end
