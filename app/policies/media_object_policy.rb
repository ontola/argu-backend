# frozen_string_literal: true
class MediaObjectPolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  def initialize(context, record)
    @context = context
    @record = record
  end

  def permitted_attributes
    attributes = []
    attributes.concat %i(id used_as content remote_content remove_content content_cache content_aspect
                         content_attribution content_box_w content_crop_h content_crop_w content_crop_x content_crop_y
                         content_original_h content_original_w _destroy description)
    attributes
  end

  def show?
    return super if edge.present?
    Pundit.policy(context, record.about).show?
  end

  private

  alias show_roles default_show_roles
  alias show_unpublished_roles default_show_unpublished_roles

  def edge
    record.about.try(:edge)
  end
end
