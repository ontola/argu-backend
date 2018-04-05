# frozen_string_literal: true

class BannerDismissalPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attribute_names
    attributes = super
    if create?
      attributes.concat %i[title forum cited_profile content profile_photo
                           cited_name cited_function published_at]
    end
    attributes.append :id if staff?
    attributes
  end

  def create?
    case record.banner.audience.to_sym
    when :guests then user.guest?
    when :users then !user.guest?
    when :everyone then true
    end
  end

  private

  def edgeable_record
    @edgeable_record ||= record.banner.parent_model
  end
end
