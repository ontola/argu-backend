# frozen_string_literal: true

class MediaObjectPolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[used_as content_source]
  permit_attributes %i[content content_type position_y remote_content_url filename]

  def initialize(context, record) # rubocop:disable Lint/MissingSuper
    @context = context
    @record = record
  end

  def edge
    record.about if record.about.is_a?(Edge)
  end

  def create?
    edgeable_record.enhanced_with?(Attachable) && edgeable_policy.update?
  end

  def show?
    return true if record.profile_photo?

    edgeable_policy.show?
  end

  def destroy?
    edgeable_policy.update?
  end
end
