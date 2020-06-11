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

  def edge
    record.about if record.about.is_a?(Edge)
  end

  def create?
    edgeable_record.is_a?(Page) && edgeable_policy.update?
  end

  def show?
    return true if record.profile_photo?

    edgeable_policy.show?
  end

  def permitted_attribute_names
    attributes = []
    attributes.concat %i[id used_as content remote_content_url remove_content content_cache content_aspect
                         content_attribution content_box_w content_crop_h content_crop_w content_crop_x content_crop_y
                         content_original_h content_original_w _destroy content_url description position_y content_type]
    attributes.append(content_attributes: %i[position_y])
    attributes
  end
end
