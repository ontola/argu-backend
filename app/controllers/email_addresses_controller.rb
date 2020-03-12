# frozen_string_literal: true

class EmailAddressesController < ParentableController
  include LinkedRails::Enhancements::Creatable::Controller

  private

  def active_response_success_message
    return super unless action_name == 'create'

    I18n.t('email_addresses.create.success')
  end

  def create_execute
    update_execute
  end

  def redirect_location
    current_user.menu(:profile).iri(fragment: :settings)
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
      action = e.action(:make_primary, user_context)
      [
        action.iri,
        NS::SCHEMA[:actionStatus],
        action.action_status,
        delta_iri(:replace)
      ]
    end
  end
end
