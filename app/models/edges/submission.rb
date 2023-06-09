# frozen_string_literal: true

class Submission < Edge
  include DeltaHelper

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance Couponable

  with_columns default: [
    NS.schema.dateCreated,
    NS.argu[:submissionStatus],
    NS.argu[:submissionData]
  ]

  property :session_id, :string, NS.argu[:sessionID]
  property :status, :integer, NS.argu[:submissionStatus], default: 0, enum: {
    submission_active: 0,
    submission_completed: 1
  }
  property :submission_data_id, :linked_edge_id, NS.argu[:submissionData], association_class: 'Thing'
  attr_accessor :body_slice

  after_save :store_submission_data
  parentable :survey

  def display_name; end

  def added_delta
    [
      invalidate_resource_delta(parent.submission_collection.action(:create)),
      invalidate_resource_delta(parent.menu(:tabs))
    ]
  end

  def complete_iri
    iri('submission%5Bstatus%5D': :submission_completed)
  end

  def require_coupon?
    parent.coupon_required? && super
  end

  private

  def store_submission_data
    return if body_slice.blank?

    self.submission_data ||= Thing.new(parent: self, creator: creator, publisher: publisher)
    submission_data.assign_slice(body_slice)
    submission_data.rdf_type = NS.argu[:SubmissionData]
    submission_data.save!
  end

  class << self
    def interact_as_guest?
      true
    end
  end
end
