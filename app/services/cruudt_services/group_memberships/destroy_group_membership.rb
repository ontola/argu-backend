# frozen_string_literal: true

class DestroyGroupMembership < DestroyService
  def initialize(resource, attributes: {}, options: {})
    super(resource, attributes: attributes.merge(end_date: Time.current), options: options)
  end

  private

  def service_method
    :save!
  end
end
