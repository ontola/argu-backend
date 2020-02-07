# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Actions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    %i[nt json_api]
  end

  def self.show_formats
    %i[nt json_api]
  end

  let(:index_path) do
    expand_uri_template(
      :action_items_iri,
      parent_iri: split_iri_segments("/#{argu.url}#{subject.resource.iri.path}/actions")
    )
  end
  let(:expect_get_show_guest_serializer) { expect_unauthorized }
  let(:expect_get_index_guest_serializer) { expect_unauthorized }

  context 'for notification read' do
    subject do
      NotificationActionList.new(
        resource: notification,
        user_context: UserContext.new(
          doorkeeper_scopes: 'user',
          user: authorized_user,
          profile: authorized_user.profile
        )
      ).action(:read)
    end
    let(:notification) { Notification.first }
    let(:non_existing_notification) { Notification.new(id: non_existing_id) }
    let(:authorized_user) { notification.user }
    let(:non_existing_index_path) do
      expand_uri_template(
        :action_items_iri,
        parent_iri: split_iri_segments("#{non_existing_notification.iri.path}/actions")
      )
    end
    let(:non_existing_show_path) { non_existing_notification.iri }

    it_behaves_like 'get show'
    it_behaves_like 'get index'
  end
end
