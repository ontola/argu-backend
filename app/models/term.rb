# frozen_string_literal: true

class Term < VirtualResource
  include LinkedRails::Model
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable
  attr_accessor :referrer

  def id; end

  def iri_opts
    {referrer: referrer}
  end
end
