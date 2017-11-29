# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Actions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    %i[nt json_api]
  end

  def self.show_formats
    %i[nt json_api]
  end

  let(:show_path) { url_for([subject, :action, id: :read, only_path: true]) }
  let(:index_path) { url_for([subject, :actions, only_path: true]) }
  let(:expect_get_show_guest_serializer) { expect_unauthorized }
  let(:expect_get_index_guest_serializer) { expect_unauthorized }

  context 'for notification read' do
    subject { Notification.first }
    let(:unauthorized_user) { create(:user) }
    let(:authorized_user) { subject.user }
    let(:non_existing_index_path) { url_for([:notification, :actions, notification_id: -1, only_path: true]) }

    it_behaves_like 'get show'
    it_behaves_like 'get index'
  end
end
