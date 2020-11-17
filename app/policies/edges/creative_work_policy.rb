# frozen_string_literal: true

class CreativeWorkPolicy < EdgePolicy
  permit_attributes %i[display_name description]
end
