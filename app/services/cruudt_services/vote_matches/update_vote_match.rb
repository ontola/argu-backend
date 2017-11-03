# frozen_string_literal: true

class UpdateVoteMatch < UpdateService
  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    @voteables = attributes.delete(:voteables)
    @vote_comparables = attributes.delete(:vote_comparables)
    super
  end

  private

  def after_save
    resource.replace_voteables(@voteables) if @voteables.present?
    resource.replace_vote_comparables(@vote_comparables) if @vote_comparables.present?
  end
end
