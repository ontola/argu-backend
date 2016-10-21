# frozen_string_literal: true
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
  # Scoped on wether the activity is published for the user
  # @param user [User] The user to scope on
  # @return [Activity] The latest published happening
  def latest_happening(user)
    happenings.published_for_user(user)
              .where('created_at < ?', DateTime.current)
              .order('created_at DESC')
              .last
  end
end
