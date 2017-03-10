# frozen_string_literal: true
class ProfilePolicy < RestrictivePolicy
  class Scope < Scope
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
    attributes.concat %i(id name about are_votes_public is_public)
    append_default_photo_params(attributes)
    attributes
  end

  def show?
    Pundit.policy(context, record.profileable).show?
  end
  deprecate show?: 'Please use the more consise method on profileable instead.'

  def update?
    Pundit.policy(context, record.profileable).update? || super
  end

  def index_votes?
    record.are_votes_public? || Pundit.policy(context, record.profileable).update?
  end

  private

  def is_manager_somewhere?
    user.profile.grants.manager.present?
  end

  def is_owner_somewhere?
    user.profile.pages.present?
  end
end
