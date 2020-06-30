# frozen_string_literal: true

class CustomActionPolicy < EdgePolicy
  permit_attributes %i[raw_label label_translation raw_description description_translation raw_submit_label]
  permit_attributes %i[submit_label_translation href]
end
