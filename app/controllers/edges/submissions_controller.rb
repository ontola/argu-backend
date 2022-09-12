# frozen_string_literal: true

class SubmissionsController < EdgeableController
  has_resource_action(
    :submit,
    form: -> { resource.parent.action_body&.iri },
    http_method: :put,
    policy: :update?,
    target_url: -> { resource.complete_iri }
  )

  private

  def active_response_custom_responses(format)
    return unless action_name == 'index'

    skip_verify_policy_scoped(sure: true)
    format.csv do
      send_data(
        Submission.collection_csv(requested_resource),
        filename: "#{requested_resource.display_name}-#{Time.current.to_i}"
      )
    end
  end

  def allow_empty_params?
    true
  end

  def create_success
    add_exec_action_header(response.headers, ontola_dialog_action(current_resource.iri))

    super
  end

  def create_success_location
    parent_resource.iri
  end

  def create_success_message; end

  def permit_params
    super.merge(body_slice: request.env['emp_json'])
  end

  def update_meta
    super + [
      invalidate_resource_delta(current_resource.action(:submit)),
      invalidate_resource_delta(parent_resource.menu(:tabs))
    ]
  end

  def update_success_message; end

  def update_success_location
    parent_resource.iri
  end
end
