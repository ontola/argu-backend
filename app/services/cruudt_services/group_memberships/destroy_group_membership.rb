# frozen_string_literal: true

class DestroyGroupMembership < DestroyService
  def initialize(resource, attributes: {}, options: {})
    attributes = {end_date: Time.current}
    super
  end

  private

  def service_method
    :save!
  end
end
