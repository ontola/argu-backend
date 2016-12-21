
# frozen_string_literal: true
class CreateArgument < PublishedCreateService
  private

  def after_save
    super
    return unless @options[:auto_vote]
    ::CreateVote
      .new(
        resource.edge,
        attributes: {
          for: :pro,
          voter: resource.creator
        },
        options: {
          creator: resource.creator,
          publisher: resource.creator.profileable
        }
      )
      .commit
  end
end
