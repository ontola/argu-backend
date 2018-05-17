# frozen_string_literal: true

# Concern which gives Models the ability to render a timeline of Happenables.
module Timelineable
  extend ActiveSupport::Concern

  included do
    has_many :happenings,
             -> { where("key ~ '*.happened'").order(created_at: :asc) },
             class_name: 'Activity',
             foreign_key: :recipient_edge_id,
             inverse_of: :recipient,
             primary_key: :uuid
  end
end
