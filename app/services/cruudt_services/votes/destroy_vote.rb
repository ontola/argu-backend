# frozen_string_literal: true
class DestroyVote < DestroyService
  include Wisper::Publisher

  def initialize(vote, attributes: {}, options: {})
    @vote = vote
    super
  end

  def resource
    @vote
  end
end
