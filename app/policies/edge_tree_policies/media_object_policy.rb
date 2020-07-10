# frozen_string_literal: true

class MediaObjectPolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[used_as content_source]
  permit_attributes %i[content content_type position_y remote_content_url remove_content]

  def initialize(context, record)
    @context = context
    @record = record
  end

  def edge
    record.about if record.about.is_a?(Edge)
  end

  def create?
    edgeable_record.is_a?(Page) && edgeable_policy.update?
  end

  def show?
    return true if record.profile_photo?

    edgeable_policy.show?
  end
end
