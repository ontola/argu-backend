
class CreateComment < ApplicationService
  include Wisper::Publisher

  def initialize(profile, attributes = {})
    @comment = profile.comments.new(attributes)
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @comment.publisher = profile.profileable
    end
  end

  def resource
    @comment
  end

  def commit
    if @comment.valid? && @comment.save
      @comment.publisher.follow(@comment)
      publish(:create_comment_successful, @comment)
    else
      publish(:create_comment_failed, @comment)
    end
  end

end
