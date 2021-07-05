# frozen_string_literal: true

class Submission < Edge
  include DeltaHelper

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance Couponable

  with_columns default: [
    NS.schema.dateCreated,
    NS.argu[:submissionStatus]
  ]

  property :session_id, :string, NS.argu[:sessionID]
  property :status, :integer, NS.argu[:submissionStatus], default: 0, enum: {
    submission_active: 0,
    submission_completed: 1
  }

  parentable :survey

  def display_name; end

  def added_delta
    [
      invalidate_resource_delta(parent.submission_collection.action(:create)),
      invalidate_resource_delta(parent.menu(:settings))
    ]
  end

  def require_coupon?
    parent.has_reward? && super
  end

  def reward_iri
    RDF::URI('https://acegif.com/wp-content/gifs/raining-money-8.gif')
  end

  class << self
    def interact_as_guest?
      true
    end
  end
end
