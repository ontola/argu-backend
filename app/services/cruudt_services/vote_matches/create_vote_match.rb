# frozen_string_literal: true
class CreateVoteMatch < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = VoteMatch.new
    attributes[:publisher] = options.fetch(:publisher)
    attributes[:creator] = options.fetch(:creator)
    super
  end
end
