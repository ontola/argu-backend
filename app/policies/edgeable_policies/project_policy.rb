# frozen_string_literal: true

class ProjectPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end
  include ApplicationHelper

  def permitted_attributes
    attributes = super
    attributes.concat %i[id title content start_date end_date achieved_end_date email cover_photo remove_cover_photo
                         cover_photo_attribution unpublish] if create?
    attributes.concat %i[pinned] if is_manager? || staff?
    phase = record.is_a?(Project) && Edge.new(owner: Phase.new, parent: record.edge).owner
    attributes.append(phases_attributes: Pundit.policy(context, phase).permitted_attributes(true)) if phase && create?
    append_default_photo_params(attributes)
    attributes
  end

  def create?
    return unless active_for_user?(:projects, user)
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    rule is_manager?, is_super_admin?, super
  end

  def list?
    if record.is_published? && !record.is_trashed?
      rule is_member?, is_manager?, is_super_admin?, super
    else
      rule is_manager?, is_super_admin?, super
    end
  end

  def update?
    rule is_manager?, is_super_admin?, super
  end
end
