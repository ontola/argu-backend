# frozen_string_literal: true

class BlogPostPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description trashed_at happened_at] if create?
    happening_attributes = %i[id happened_at]
    attributes.append(happening_attributes: happening_attributes)
    attributes
  end

  def feed?
    false
  end

  def create_expired?
    has_grant?(:create)
  end
end
