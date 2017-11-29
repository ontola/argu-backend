# frozen_string_literal: true

class ProjectPolicy < EdgeablePolicy
  def permitted_attributes
    attributes = super
    if create?
      attributes.concat %i[id title content start_date end_date achieved_end_date email cover_photo remove_cover_photo
                           cover_photo_attribution unpublish]
    end
    attributes.concat %i[pinned] if moderator? || administrator? || staff?
    phase = record.is_a?(Project) && Edge.new(owner: Phase.new, parent: record.edge).owner
    attributes.append(phases_attributes: Pundit.policy(context, phase).permitted_attributes(true)) if phase && create?
    append_default_photo_params(attributes)
    attributes
  end

  def create?
    false
  end
end
