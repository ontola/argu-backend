
class CreateComment < CreateService
  include Wisper::Publisher

  def initialize(comment, attributes = {})
    @comment = comment
    super
  end

  def resource
    @comment
  end
end
