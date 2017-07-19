# frozen_string_literal: true
class CommentPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i(body parent_id) if create?
    attributes
  end

  private

  def assert_siblings!
    assert! record.parent_model == record.parent.parent_model, :siblings?
  end

  def create_asserts
    assert_siblings! if record.try(:parent_id).present?
    super
  end

  def create_expired_roles
    return super unless record.parent_model.is_a?(BlogPost)
    [is_member?, is_manager?, is_super_admin?, staff?, super]
  end

  def update_roles
    is_creator?
  end

  def destroy_roles
    default_destroy_roles unless record.deleted?
  end

  def trash_roles
    default_trash_roles unless record.deleted?
  end

  def untrash_roles
    default_untrash_roles unless record.deleted?
  end

  alias create_roles default_create_roles
  alias show_roles default_show_roles
  alias show_unpublished_roles default_show_unpublished_roles
end
