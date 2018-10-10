# frozen_string_literal: true

class Term < VirtualResource
  include Ldable
  include Iriable
  enhance Actionable
  enhance Createable
  attr_accessor :referrer

  def id; end

  def iri_opts
    {referrer: referrer}
  end
end
