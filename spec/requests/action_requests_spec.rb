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

  let(:expect_get_show_guest_serializer) { expect_unauthorized }

  context 'for notification read' do
    subject do
      NotificationActionList.new(resource: notification).action(:read)
    end

    let(:notification) { Notification.first }
    let(:authorized_user) { notification.user }
    let(:show_path) { "/argu/n/#{notification.id}/actions/read" }
    let(:non_existing_show_path) { "/argu/n/#{non_existing_id}/actions/read" }

    it_behaves_like 'get show'
  end
end
