# frozen_string_literal: true

class VocabularyPolicy < EdgePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      scope
    end
  end
  permit_attributes %i[display_name description tagged_label]

  delegate :show?, to: :parent_policy
end
