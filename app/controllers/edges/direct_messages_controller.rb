# frozen_string_literal: true

class DirectMessagesController < ParentableController
  private

  def confirmed_email_addresses
    current_user.email_addresses.confirmed
  end

  def create_execute # rubocop:disable Metrics/AbcSize
    authenticated_resource.assign_attributes(permit_params)
    authenticated_resource.actor = current_actor.actor
    return false unless authenticated_resource.valid?

    unless authenticated_resource.email_address.confirmed? && authenticated_resource.email_address.user == current_user
      raise Argu::Errors::Forbidden.new(record: authenticated_resource, query: 'email?')
    end

    authenticated_resource.send_email!
  end

  def new_success
    authenticated_resource.email_address = current_user.primary_email_record if current_user.confirmed?
    super
  end

  def parent_resource
    return super if parent_resource_param(params)

    @parent_resource ||= LinkedRails.resource_from_iri(params[:direct_message].try(:[], :resource_iri))
  end

  def requested_resource; end

  def redirect_location
    authenticated_resource.resource.iri
  end

  def resource_new_params
    {
      actor: current_profile.iri,
      email_address_id: confirmed_email_addresses.any? ? current_user.primary_email_record.iri : nil,
      resource: parent_resource
    }
  end

  def active_response_success_message
    return super unless action_name == 'create'

    I18n.t('direct_messages.notice.success')
  end
end