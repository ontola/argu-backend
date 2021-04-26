# frozen_string_literal: true

class VocabularyPolicy < EdgePolicy
  permit_attributes %i[display_name description tagged_label]
end
