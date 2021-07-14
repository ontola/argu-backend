# frozen_string_literal: true

class SubmissionsController < EdgeableController
  has_resource_action(
    :submit,
    form: -> { resource.parent.action_body },
    http_method: :put,
    policy: :update?,
    target_url: -> { resource.iri('submission%5Bstatus%5D': :submission_completed) }
  )

  private

  def allow_empty_params?
    true
  end

  def create_success
    add_exec_action_header(response.headers, ontola_dialog_action(current_resource.iri, opener: parent_resource.iri))

    super
  end

  def create_success_location
    parent_resource.iri
  end

  def create_success_message; end

  def update_meta
    super + [
      invalidate_resource_delta(current_resource),
      invalidate_resource_delta(current_resource.action(:submit)),
      invalidate_resource_delta(parent_resource.menu(:settings))
    ]
  end

  def update_success_message; end

  def update_success_location
    parent_resource.iri
  end
end
