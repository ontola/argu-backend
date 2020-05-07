# frozen_string_literal: true

class ActiveBannerPolicy < BannerPolicy
  class Scope < Scope
    def resolve # rubocop:disable Metrics/AbcSize
      audience = [Banner.audiences[:everyone]]
      audience << Banner.audiences[:guests] if user.guest?
      audience << Banner.audiences[:users] unless user.guest?
      dismissed = BannerDismissal.where_with_redis(creator: @profile).pluck(:parent_id)

      scope
        .active
        .where('expires_at IS NULL OR expires_at > statement_timestamp()')
        .where(audience: audience)
        .where.not(id: dismissed)
    end
  end

  def show?
    true
  end
end
