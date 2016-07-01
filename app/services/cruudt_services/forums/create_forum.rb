# frozen_string_literal: true
class CreateForum < EdgeableCreateService
  include Wisper::Publisher

  private

  def object_attributes=(obj)
  end
end
