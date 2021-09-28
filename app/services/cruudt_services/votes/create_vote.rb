# frozen_string_literal: true

class CreateVote < CreateEdge
  def initialize(parent, attributes: {}, options: {})
    attributes[:option_id] ||= option_id_from_iri(parent, attributes.delete(:option))

    super
  end

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
        option_id: attributes[:option_id],
        publisher: user,
        primary: true
      ).find_by(parent: parent)
  end

  def initialize_edge(parent, attributes)
    existing_edge(parent, attributes) || super
  end

  def option_id_from_iri(parent, iri)
    parent.option_record(iri).uuid if iri.present?
  end
end
