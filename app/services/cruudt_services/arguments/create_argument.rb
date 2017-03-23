
# frozen_string_literal: true
class CreateArgument < PublishedCreateService
  private

  def after_save
    super
    resource.upvote(resource.creator.profileable, resource.creator) if @options[:auto_vote]
  end
end
