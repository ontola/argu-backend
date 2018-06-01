# frozen_string_literal: true

module ContextHelper
  # Renders a to_parent breadcrumb block
  def  to_parent(parent = nil)
    if parent.blank?
      parent =
        if authenticated_resource.is_a?(Forum)
          authenticated_resource
        else
          authenticated_resource.parent
        end
    end
    return unless policy(parent).show?
    render partial: 'contextualize/to_parent',
           locals: {
             parent: parent
           }
  end
end
