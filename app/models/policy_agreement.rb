# frozen_string_literal: true

class PolicyAgreement < VirtualResource
  include LinkedRails::Model
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable

  def id; end
end
