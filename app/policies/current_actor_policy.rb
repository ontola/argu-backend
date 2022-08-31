# frozen_string_literal: true

class CurrentActorPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
    forbid_wrong_tier if forbid_post_as_org?

    moderator?
  end

  def update?
    forbid_wrong_tier if forbid_post_as_org?

    moderator?
  end

  private

  def confirmed?
    record.user.confirmed?
  end

  def moderator? # rubocop:disable Metrics/AbcSize
    profile_owner = record.profile.profileable

    if profile_owner.instance_of?(User)
      profile_owner == record.user
    else
      return forbid_with_message(I18n.t('actions.current_actors.create.errors.unconfirmed')) unless confirmed?

      record.profile == record.user.profile || user_context.managed_profile_ids.include?(record.profile.id)
    end
  end

  def forbid_post_as_org?
    record.profile.profileable.is_a?(Page) && !feature_enabled?(:post_as_org)
  end
end
