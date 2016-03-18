
class CreateQuestion < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {}, options = {})
    @question = profile.questions.new
    super
    if attributes[:publisher].blank? && profile.profileable.is_a?(User)
      @question.publisher = profile.profileable
    end
  end

  def resource
    @question
  end
end
