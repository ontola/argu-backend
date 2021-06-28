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

  def update_meta
    meta = super
    meta.concat(primary_change_meta) if current_resource.previous_changes.key?(:primary)
    meta
  end

  def primary_change_meta # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    current_user
      .email_addresses
      .flat_map do |e|
      primary_action = e.action(:make_primary, user_context)
      delete_action = e.action(:destroy, user_context)
      [
        RDF::Statement.new(
          primary_action.iri,
          NS.schema.actionStatus,
          primary_action.action_status,
          graph_name: delta_iri(:replace)
        ),
        RDF::Statement.new(
          delete_action.iri,
          NS.schema.actionStatus,
          delete_action.action_status,
          graph_name: delta_iri(:replace)
        )
      ]
    end
  end
end
