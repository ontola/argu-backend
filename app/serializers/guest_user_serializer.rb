# frozen_string_literal: true

class GuestUserSerializer < BaseSerializer
  attribute :display_name, predicate: NS::SCHEMA[:name]

  def type
    NS::SCHEMA[:Person]
  end
end
