# frozen_string_literal: true
class ProjectPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end
  include ApplicationHelper

  def permitted_attributes
    attributes = super
    attributes.concat %i(id title content start_date end_date achieved_end_date email cover_photo remove_cover_photo
                         cover_photo_attribution unpublish) if create?
    attributes.concat %i(pinned) if is_manager? || staff?
    phase = record.is_a?(Project) && Edge.new(owner: Phase.new, parent: record.edge).owner
    attributes.append(phases_attributes: Pundit.policy(context, phase).permitted_attributes) if phase && create?
    append_default_photo_params(attributes)
    attributes
  end
end
