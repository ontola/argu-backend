# frozen_string_literal: true
class CreateVoteMatch < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = VoteMatch.new
    @voteables = attributes.delete(:voteables)
    @vote_comparables = attributes.delete(:vote_comparables)
    attributes[:publisher] = options.fetch(:publisher)
    attributes[:creator] = options.fetch(:creator)
    super
  end

  private

  def after_save
    resource.replace_voteables(@voteables) if @voteables.present?
    resource.replace_vote_comparables(@vote_comparables) if @vote_comparables.present?
  end
end
