class TrashQuestion < TrashService
  include Wisper::Publisher

  def initialize(question, options = {})
    @question = question
    super
  end

  def resource
    @question
  end
end
