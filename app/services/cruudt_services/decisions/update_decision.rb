# frozen_string_literal: true
class UpdateDecision < UpdateService
  include Wisper::Publisher

  def initialize(decision, attributes: {}, options: {})
    @decision = decision
    super
  end

  def resource
    @decision
  end

  private

  def object_attributes=(obj)
  end
end
