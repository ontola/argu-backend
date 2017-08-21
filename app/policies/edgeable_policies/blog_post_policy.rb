# frozen_string_literal: true
class BlogPostPolicy < EdgeablePolicy
  def create?
    assert_publish_type
    super
  end

  def feed?
    false
  end
end
