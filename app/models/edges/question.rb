# frozen_string_literal: true

class Question < Discussion
  enhance CoverPhotoable
  enhance Motionable
  enhance GrantResettable
  enhance ChildrenPlaceable

  include Edgeable::Content

  convertible(
    motions: %i[activities media_objects],
    topics: %i[activities media_objects]
  )
  parentable :container_node, :phase

  validates :description, presence: true, length: {minimum: 5, maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {minimum: 4, maximum: 110}
  validates :creator, presence: true
  # TODO: validate expires_at

  custom_grants_for :motions, :create

  property :map_question, :boolean, NS.argu[:mapQuestion], default: false
  property :require_location, :boolean, NS.argu[:requireLocation], default: false
  property :default_motion_sorting,
           :integer,
           NS.argu[:defaultSorting],
           default: 0,
           enum: {popular: 0, created_at: 1, updated_at: 2, popular_asc: 3, created_at_asc: 4, updated_at_asc: 5}
  property :default_motion_display,
           :integer,
           NS.argu[:defaultDisplay],
           default: 0,
           enum: {default_display: 0, grid_display: 1, table_display: 2}

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def location_query
    return nil unless map_question?

    @location_query ||= LinkedRails::PropertyQuery.new(
      iri: location_query_iri,
      force_render: true,
      target_node: iri,
      path: NS.schema.location
    )
  end

  def location_query_iri
    LinkedRails.iri(path: root_relative_iri, fragment: 'location') unless anonymous_iri?
  end

  class << self
    def route_key
      :q
    end
  end
end
