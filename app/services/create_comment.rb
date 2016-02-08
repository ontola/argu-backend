
class CreateComment < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {})
    @comment = profile.comments.new
    super
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @comment.publisher = profile.profileable
    end
  end

  def resource
    @comment
  end

end
