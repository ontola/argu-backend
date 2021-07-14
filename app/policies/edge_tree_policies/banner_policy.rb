# frozen_string_literal: true

class BannerPolicy < EdgePolicy
  class Scope < Scope
    def resolve # rubocop:disable Metrics/AbcSize
      return scope.none if user.nil?

      audience = [Banner.audiences[:everyone]]
      audience << Banner.audiences[:guests] if user.guest?
      audience << Banner.audiences[:users] unless user.guest?
      dismissed = BannerDismissal.where_with_redis(publisher: user).pluck(:parent_id)

      scope
        .active
        .where('expires_at IS NULL OR expires_at > statement_timestamp()')
        .where(audience: audience)
        .where.not(id: dismissed)
    end
  end

  permit_attributes %i[display_name description audience published_at expires_at dismiss_button]

  def show?
    return if has_unpublished_ancestors? && !show_unpublished?

    true
  end
end
