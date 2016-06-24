class TrashComment < TrashService
  include Wisper::Publisher

  def initialize(comment, attributes: {}, options: {})
    @comment = comment
    super
  end

  def resource
    @comment
  end
end
