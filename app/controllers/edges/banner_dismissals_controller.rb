# frozen_string_literal: true

class BannerDismissalsController < EdgeableController
  has_collection_create_action(
    label: -> { '' },
    submit_label: -> { resource.parent.dismiss_button }
  )

  private

  def active_response_success_message; end

  def allow_empty_params?
    true
  end
end
