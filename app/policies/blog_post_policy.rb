# frozen_string_literal: true
class BlogPostPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i(title content trashed_at happened_at) if create?
    happening_attributes = %i(id happened_at)
    attributes.append(happening_attributes: happening_attributes)
    append_attachment_params(attributes)
    attributes
  end

  def feed?
    false
  end

  private

  def create_asserts
    assert_publish_type
    super
  end

  def create_roles
    [is_manager?, is_super_admin?, super]
  end

  alias destroy_roles default_destroy_roles
  alias trash_roles default_trash_roles
  alias untrash_roles default_untrash_roles
  alias update_roles default_update_roles
  alias show_roles default_show_roles
  alias show_unpublished_roles default_show_unpublished_roles
end
