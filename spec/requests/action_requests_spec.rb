# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Actions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    %i[nq hndjson]
  end

  def self.show_formats
    %i[nq hndjson]
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
    let(:authorized_user) { notification.user }
    let(:non_existing_index_path) do
      expand_uri_template(
        :action_items_iri,
        parent_iri: split_iri_segments("/n/#{non_existing_id}/actions")
      )
    end
    let(:non_existing_show_path) { "/n/#{non_existing_id}" }

    it_behaves_like 'get show'
    it_behaves_like 'get index'
  end
end
