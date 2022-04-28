# frozen_string_literal: true

class SubmissionsController < EdgeableController
  has_resource_action(
    :submit,
    form: -> { resource.parent.action_body.iri },
    http_method: :put,
    policy: :update?,
    target_url: -> { resource.iri('submission%5Bstatus%5D': :submission_completed) }
  )
  has_resource_action(
    :claim_reward,
    http_method: :get,
    policy: :reward?,
    target_url: -> { resource.reward_iri }
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

  def permit_params
    super.merge(body_graph: params[:body_graph])
  end

  def update_meta
    super + [
      invalidate_resource_delta(current_resource),
      invalidate_resource_delta(current_resource.action(:submit)),
      invalidate_resource_delta(parent_resource.menu(:tabs))
    ]
  end

  def update_success_message; end

  def update_success_location
    parent_resource.iri
  end
end
