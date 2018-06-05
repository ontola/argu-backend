# frozen_string_literal: true

class BlogPostPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description trashed_at] if create?
    attributes
  end

  def feed?
    false
  end

  def create_expired?
    has_grant?(:create)
  end
end
