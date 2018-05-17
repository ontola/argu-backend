# frozen_string_literal: true

class CreateVote < PublishedCreateService
  private

  def after_save
    super
    resource.publisher.follow(@edge, nil, :news)
    @edge.parent.reload
  end

  def existing_edge(parent, options, attributes)
    Edge
      .where_owner(
        'Vote',
        for: Vote.fors[attributes[:for]] || attributes[:for],
        creator: options[:creator],
        primary: true
      ).find_by(parent: parent)
  end

  def initialize_edge(parent, options, attributes)
    existing_edge(parent, options, attributes) || super
  end
end
