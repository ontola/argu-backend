
# frozen_string_literal: true
class CreateArgument < PublishedCreateService
  include Wisper::Publisher

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

  def parent_columns
    %i(forum_id motion_id)
  end
end
