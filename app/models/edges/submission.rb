# frozen_string_literal: true

class Submission < Edge
  include DeltaHelper

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance Couponable

  collection_options(
    download_urls: -> { [Submission.download_url(self)] }
  )
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
    def default_columns
      [
        {key: :created_at, label: I18n.t('schema.dateCreated.label')},
        {key: :status, label: I18n.t('argu.submissionStatus.label')}
      ]
    end

    def form_field_columns(submission)
      submission.action_body.custom_form_fields.map do |field|
        {
          key: field.sh_path.to_s,
          label: field.display_name
        }
      end
    end

    def collection_csv(collection)
      submission = collection.parent
      columns = default_columns + form_field_columns(submission)

      Argu::CSVBuilder
        .new(columns: columns, rows: collection.association_base.includes(:submission_data))
        .generate do |row, column|
        csv_row(row, column)
      end
    end

    def csv_row(row, column)
      if column[:key].is_a?(Symbol)
        row.send(column[:key])
      else
        row.submission_data&.cached_properties.try(:[], column[:key])&.join(', ')
      end
    end

    def download_url(collection)
      iri = collection.iri.dup
      iri.path += '.csv'
      iri
    end

    def interact_as_guest?
      true
    end
  end
end
