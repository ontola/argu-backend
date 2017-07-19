# frozen_string_literal: true
class ProjectPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end
  include ApplicationHelper

  def permitted_attributes
    attributes = super
    attributes.concat %i(id title content start_date end_date achieved_end_date email cover_photo remove_cover_photo
                         cover_photo_attribution unpublish)
    attributes.concat %i(pinned) if is_manager? || staff?
    phase = record.is_a?(Project) && Edge.new(owner: Phase.new, parent: record.edge).owner
    attributes.append(phases_attributes: Pundit.policy(context, phase).permitted_attributes(true)) if phase
    append_default_photo_params(attributes)
    attributes
  end

  def list?
    if record.is_published? && !record.is_trashed?
      rule is_member?, is_manager?, is_super_admin?, super
    else
      rule is_manager?, is_super_admin?, super
    end
  end

  private

  def create_asserts
    assert_publish_type
    super
  end

  def create_roles
    []
  end

  alias destroy_roles default_destroy_roles
  alias trash_roles default_trash_roles
  alias untrash_roles default_untrash_roles
  alias update_roles default_update_roles
  alias show_roles default_show_roles
  alias show_unpublished_roles default_show_unpublished_roles
end
