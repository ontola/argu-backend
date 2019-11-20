# frozen_string_literal: true

class Term < VirtualResource
  include LinkedRails::Model
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable

  def id; end
end
