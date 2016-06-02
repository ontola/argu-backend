class TrashComment < TrashService
  include Wisper::Publisher

  def initialize(comment, options = {})
    @comment = comment
    super
  end

  def resource
    @comment
  end
end
