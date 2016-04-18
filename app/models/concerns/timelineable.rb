# Concern which gives Models the ability to render a timeline of Happenables.
module Timelineable
  extend ActiveSupport::Concern

  included do
    has_many :happenings,
             -> { where("key ~ '*.happened'").order(created_at: :asc) },
             class_name: 'Activity',
             as: :recipient,
             inverse_of: :recipient
  end

  # Fetches the latest published happening which already happened.
  # @return [Activity] The latest published happening
  def latest_happening(show_unpublished = false)
    happenings.published(show_unpublished)
      .where('created_at < ?', DateTime.current)
      .order('created_at DESC')
      .last
  end
end
