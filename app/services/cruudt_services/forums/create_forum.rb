# frozen_string_literal: true
class CreateForum < ContentCreateService
  include Wisper::Publisher

  def resource_klass
    Forum
  end

  private

  def object_attributes=(obj)
  end
end
