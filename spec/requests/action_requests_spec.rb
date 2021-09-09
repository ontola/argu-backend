# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Actions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  def self.index_formats
    %i[nquads hndjson]
  end

  def self.show_formats
    %i[nquads hndjson]
  end

  let(:expect_get_show_guest_serializer) { expect_unauthorized }

  context 'for notification read' do
    subject do
      notification.action(:update).iri
    end

    let(:notification) { Notification.first }
    let(:authorized_user) { notification.user }
    let(:show_path) { "/argu/n/#{notification.id}/read" }
    let(:non_existing_show_path) { "/argu/n/#{non_existing_id}/read" }

    it_behaves_like 'get show'
  end
end
