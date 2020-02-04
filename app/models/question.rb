# frozen_string_literal: true

class Question < Discussion
  enhance CoverPhotoable
  enhance Motionable
  enhance GrantResettable
  enhance ChildrenPlaceable

  include Edgeable::Content

  convertible motions: %i[activities media_objects]
  parentable :container_node, :phase

  validates :description, presence: true, length: {minimum: 5, maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {minimum: 5, maximum: 110}
  validates :creator, presence: true
  # TODO: validate expires_at

  custom_grants_for :motions, :create

  property :require_location, :boolean, NS::ARGU[:requireLocation], default: false
  property :default_motion_sorting,
           :integer,
           NS::ARGU[:defaultSorting],
           default: 0,
           enum: {popular: 0, created_at: 1, updated_at: 2, popular_asc: 3, created_at_asc: 4, updated_at_asc: 5}

  def expired?
    expires_at.present? && expires_at < Time.current
  end
end
