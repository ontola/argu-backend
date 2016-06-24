class TrashQuestion < TrashService
  include Wisper::Publisher

  def initialize(question, attributes: {}, options: {})
    @question = question
    super
  end

  def resource
    @question
  end
end
