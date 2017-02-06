# frozen_string_literal: true
class MediaObjectPolicy < RestrictivePolicy
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
    attributes.concat %i(id used_as content remote_content remove_content content_cache content_aspect
                         content_attribution content_box_w content_crop_h content_crop_w content_crop_x content_crop_y
                         content_original_h content_original_w _destroy description)
    attributes
  end
end
