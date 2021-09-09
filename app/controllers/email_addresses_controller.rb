# frozen_string_literal: true

class EmailAddressesController < ParentableController
  include LinkedRails::Enhancements::Creatable::Controller
  has_resource_action(
    :send_confirmation,
    http_method: :post,
    image: 'fa-send',
    one_click: true,
    policy: :confirm?,
    target_url: lambda {
      LinkedRails.iri(path: '/u/confirmation', query: {user: {email: resource.email}}.to_param)
    }
  )

  has_resource_action(
    :make_primary,
    http_method: :put,
    image: -> { resource.primary? ? 'fa-circle' : 'fa-circle-o' },
    one_click: true,
    policy: :make_primary?,
    target_url: -> { resource.iri('email_address%5Bprimary%5D': true) }
  )

  private

  def active_response_success_message
    return super unless action_name == 'create'

    I18n.t('email_addresses.create.success')
  end

  def create_execute
    update_execute
  end

  def redirect_location
    current_user.menu(:settings).iri(fragment: :settings)
  end

  def update_meta
    meta = super
    meta.concat(primary_change_meta) if current_resource.previous_changes.key?(:primary)
    meta
  end

  def primary_change_meta
    current_user
      .email_addresses
      .flat_map do |email_address|
      action_delta(email_address.action(:make_primary, user_context)) +
        action_delta(email_address.action(:destroy, user_context))
    end
  end

  def action_delta(action) # rubocop:disable Metrics/AbcSize
    image = RDF::URI(action.image.to_s.gsub(/^fa-/, 'http://fontawesome.io/icon/'))

    [
      action_delta_statement(action.iri, NS.schema.actionStatus, action.action_status),
      action_delta_statement(action.iri, NS.schema.error, action.error),
      action_delta_statement(action.target.iri, NS.schema.image, image)
    ]
  end

  def action_delta_statement(subject, predicate, object)
    RDF::Statement.new(subject, predicate, object, graph_name: delta_iri(:replace))
  end
end
