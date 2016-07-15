# frozen_string_literal: true
module DiscussionsHelper
  # Checks if the user is able to start a top-level discussion in the current context/tenant
  # @return [Boolean] Whether the user can new? any discussion object
  def can_start_discussion?
    [
      [Question, :new?],
      [Motion, :new_without_question?],
      [Project, :new?]
    ].any? { |model, method| policy_with_tenant!(@forum || authenticated_context, model).public_send(method) }
  end
end
