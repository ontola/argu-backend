# frozen_string_literal: true
class BannerPolicy < EdgeTreePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context

    def resolve
      audience = [Banner.audiences[:everyone]]
      audience <<
        if user.member_of?(scope.build.forum)
          Banner.audiences[:members]
        elsif user.guest?
          Banner.audiences[:guests]
        else
          Banner.audiences[:users]
        end
      scope.where(audience: audience)
    end
  end

  def edge
    record.forum.edge
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(title forum cited_profile content cited_name audience
                         cited_function published_at ends_at) if create?
    append_default_photo_params(attributes)
    attributes.append :id if staff?
    attributes
  end

  def create?
    rule is_manager?, is_owner?, super
  end

  def destroy?
    rule is_manager?, is_owner?, super
  end

  def update?
    rule is_manager?, is_owner?, super
  end
end
