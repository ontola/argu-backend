# frozen_string_literal: true

class EmailAddressesController < ParentableController
  include Createable::Controller

  private

  def create_execute
    update_execute
  end

  def redirect_location
    iri_from_template(:settings_iri, fragment: :emails).to_s
  end

  def resource_new_params
    {
      user: current_user
    }
  end

  def update_meta
    meta = super
    meta.concat(primary_change_meta) if current_resource.previous_changes.key?(:primary)
    meta
  end

  def primary_change_meta
    current_user
      .email_addresses
      .map do |e|
      action = e.action(user_context, :make_primary)
      [
        action.iri,
        NS::SCHEMA[:actionStatus],
        action.action_status
      ]
    end
  end
end
