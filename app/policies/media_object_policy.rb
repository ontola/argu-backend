# frozen_string_literal: true
class MediaObjectPolicy < EdgeTreePolicy
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

  def initialize(context, record)
    @context = context
    @record = record
  end

  def edge
    record.about.try(:edge)
  end

  def show?
    if edge.present?
      return show_unpublished? if has_unpublished_ancestors?
      rule is_creator?, is_member?, is_manager?, is_owner?, super
    else
      Pundit.policy(context, record.about).show?
    end
  end

  def permitted_attributes
    attributes = []
    attributes.concat %i(id used_as content remote_content remove_content content_cache content_aspect
                         content_attribution content_box_w content_crop_h content_crop_w content_crop_x content_crop_y
                         content_original_h content_original_w _destroy description)
    attributes
  end
end
