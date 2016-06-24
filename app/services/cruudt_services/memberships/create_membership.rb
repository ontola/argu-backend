# frozen_string_literal: true
class CreateMembership < ContentCreateService
  include Wisper::Publisher

  def resource_klass
    Membership
  end

  private

  def object_attributes=(obj)
  end
end
