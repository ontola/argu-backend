# frozen_string_literal: true

class BlogPostPolicy < EdgeablePolicy
  def permitted_attributes
    attributes = super
    attributes.concat %i[title content trashed_at happened_at] if create?
    happening_attributes = %i[id happened_at]
    attributes.append(happening_attributes: happening_attributes)
    append_attachment_params(attributes)
    attributes
  end

  def feed?
    false
  end

  def create_expired?
    has_grant?(:create)
  end
end
