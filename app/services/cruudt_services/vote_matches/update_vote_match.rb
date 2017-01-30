# frozen_string_literal: true
class UpdateVoteMatch < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    @voteables = attributes.delete(:voteables)
    @comparables = attributes.delete(:comparables)
    super
  end

  private

  def after_save
    resource.replace_voteables(@voteables) if @voteables.present?
    resource.replace_comparables(@comparables) if @comparables.present?
  end
end
