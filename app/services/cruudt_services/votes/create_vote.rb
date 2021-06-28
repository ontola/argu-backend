# frozen_string_literal: true

class CreateVote < CreateEdge
  private

  def after_save
    super
    resource.publisher.follow(@edge, nil, :news)
    @edge.parent.reload
  end

  def existing_edge(parent, attributes)
    Vote
      .where_with_redis(
        root_id: ActsAsTenant.current_tenant.uuid,
        option: Vote.filter_options[NS.schema.option][:values][attributes[:option]],
        creator: profile,
        primary: true
      ).find_by(parent: parent)
  end

  def initialize_edge(parent, attributes)
    existing_edge(parent, attributes) || super
  end
end
