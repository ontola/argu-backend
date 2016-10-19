# frozen_string_literal: true
module DiscussionsHelper
  # Checks if the user is able to start a top-level discussion in the current context/tenant
  # @return [Boolean] Whether the user can new? any discussion object
  def can_start_discussion?(record)
    [:questions, :motions, :projects].any? { |model| policy(record).create_child?(model) }
  end
end
