# frozen_string_literal: true
class PhotoPolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context

    def resolve
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(id image remote_image remove_image image_cache image_aspect image_attribution image_box_w
                         image_crop_h image_crop_w image_crop_x image_crop_y image_original_h image_original_w _destroy
                         used_as)
    attributes
  end
end
