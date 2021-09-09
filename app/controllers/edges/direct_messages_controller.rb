# frozen_string_literal: true

class DirectMessagesController < ParentableController
  has_collection_create_action(
    description: lambda {
      I18n.t('actions.direct_messages.create.description', creator: resource.parent.publisher.display_name)
    },
    label: -> { I18n.t('actions.direct_messages.create.label') }
  )

  private

  def create_execute # rubocop:disable Metrics/AbcSize
    authenticated_resource.assign_attributes(permit_params)
    authenticated_resource.actor = current_profile
    return false unless authenticated_resource.valid?

    unless authenticated_resource.email_address.confirmed? && authenticated_resource.email_address.user == current_user
      raise Argu::Errors::Forbidden.new(record: authenticated_resource, query: 'email?')
    end

    authenticated_resource.send_email!
  end

  def redirect_location
    authenticated_resource.resource.iri
  end

  def active_response_success_message
    return super unless action_name == 'create'

    I18n.t('direct_messages.notice.success')
  end
end
