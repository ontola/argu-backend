# frozen_string_literal: true

class BannerDismissalPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def edge
    record.banner.forum.edge
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i[title forum cited_profile content profile_photo
                         cited_name cited_function published_at] if create?
    attributes.append :id if staff?
    attributes
  end

  def create?
    case record.banner.audience.to_sym
    when :guests then user.guest?
    when :users then !user.member_of?(context_forum)
    when :members then user.member_of?(context_forum)
    when :everyone then true
    end
  end

  private

  def context_forum
    @context_forum ||= persisted_edge.parent_model(:forum)
  end
end
