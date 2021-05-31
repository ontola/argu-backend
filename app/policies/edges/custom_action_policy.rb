# frozen_string_literal: true

class CustomActionPolicy < EdgePolicy
  permit_attributes %i[raw_label raw_description raw_submit_label href]
end
