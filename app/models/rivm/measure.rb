# frozen_string_literal: true

class Measure < Edge
  include Edgeable::Content
  enhance Attachable
  enhance Commentable
  enhance Feedable
  enhance Statable
  enhance GrantResettable

  parentable :measure_type
  validates :description, length: {maximum: 5000}
  validates :display_name, presence: true, length: {maximum: 110}
  validates :comments_allowed, presence: true
  validate :validate_parent_type

  property :comments_allowed, :integer, NS::RIVM[:commentsAllowed], enum: {
    comments_are_allowed: 1,
    comments_not_allowed: 2
  }

  def comments_allowed=(value)
    super

    current_reset = grant_resets.find_by(action: 'create', resource_type: 'Comment')
    if comments_are_allowed?
      self.grant_resets_attributes = [id: current_reset.id, _destroy: true] if current_reset
    else
      self.grant_resets_attributes = [action: 'create', resource_type: 'Comment'] unless current_reset
    end
  end

  private

  def validate_parent_type
    errors.add(:parent_id, "Invalid parent (#{parent.class})") unless parent.is_a?(MeasureType)
  end

  class << self
    def iri_namespace
      NS::RIVM
    end
  end
end
