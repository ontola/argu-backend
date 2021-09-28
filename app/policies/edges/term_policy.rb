# frozen_string_literal: true

class TermPolicy < EdgePolicy
  permit_attributes %i[display_name description exact_match]

  def create?
    return forbid_with_message('vocabularies.errors.system') if record.parent&.system?

    super
  end

  def destroy?
    return forbid_with_message('vocabularies.errors.system') if record.parent&.system?

    super
  end
end
