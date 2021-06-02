# frozen_string_literal: true

class BlogPostPolicy < EdgePolicy
  permit_attributes %i[display_name description trashed_at]

  def create_expired?
    has_grant?(:create)
  end
end
