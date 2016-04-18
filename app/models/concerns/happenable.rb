# Concern which gives Models the ability to be rendered on the timeline of a Timelineable.
module Happenable
  extend ActiveSupport::Concern

  included do
    has_one :happening,
            -> { where("key ~ '*.happened'") },
            class_name: 'Activity',
            inverse_of: :trackable,
            as: :trackable,
            dependent: :destroy,
            autosave: true
    accepts_nested_attributes_for :happening
    attr_accessor :happened_at
    delegate :happened_at, to: :happening, allow_nil: true
  end
end
