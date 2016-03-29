class DestroyComment < DestroyService
  include Wisper::Publisher

  def initialize(comment, options = {})
    @comment = comment
    super
  end

  def resource
    @comment
  end

  private
  def service_action
    :destroy
  end

  def service_method
    :wipe
  end
end
