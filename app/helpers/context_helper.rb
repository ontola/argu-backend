# frozen_string_literal: true
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
    return unless policy(parent).show?
    render partial: 'contextualize/to_parent',
           locals: {
             parent: parent
           }
  end
end
