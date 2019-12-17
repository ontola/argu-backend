# frozen_string_literal: true

class CreateVote < CreateEdge
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
        root_id: parent.root_id,
        for: attributes[:for] || Vote.filter_options[:option][:values][attributes[:option]],
        creator: options[:creator],
        primary: true
      ).find_by(parent: parent)
  end

  def initialize_edge(parent, options, attributes)
    existing_edge(parent, options, attributes) || super
  end
end
