# frozen_string_literal: true

class GuestProfile < Profile
  include NoPersistence

  def group_ids
    [Group::PUBLIC_ID]
  end

  private

  def iri_template_name
    :profiles_iri
  end
end
