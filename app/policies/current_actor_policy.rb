# frozen_string_literal: true

class CurrentActorPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
    moderator?
  end

  def update?
    moderator?
  end

  private

  def moderator? # rubocop:disable Metrics/AbcSize
    profile_owner = record.profile.profileable

    if profile_owner.instance_of?(User)
      profile_owner == record.user
    else
      return unless record.user.confirmed?

      record.profile == record.user.profile || user_context.managed_profile_ids.include?(record.profile.id)
    end
  end
end
