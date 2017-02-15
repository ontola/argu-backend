# frozen_string_literal: true
class GuestUserSerializer < BaseSerializer
  attributes :display_name

  def id
    ld_id
  end
end
