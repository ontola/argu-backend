# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Banners', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  def self.new_formats
    %i[html]
  end

  let(:expect_delete_destroy_html) do
    expect(response.code).to eq('303')
    expect(response).to redirect_to(settings_iri_path(freetown, tab: :banners))
  end
  let(:expect_post_create_failed_html) { expect_success }
  let(:expect_put_update_failed_html) { expect_success }
  let(:expect_put_update_guest_html) do
    expect(response).to redirect_to(new_user_session_path(r: settings_iri_path(freetown, tab: :banners)))
  end
  let(:expect_delete_destroy_guest_html) do
    expect(response).to redirect_to(new_user_session_path(r: settings_iri_path(freetown, tab: :banners)))
  end
  let(:expect_delete_destroy_json_api) { expect(response.code).to eq('204') }

  let(:update_path) { destroy_path }
  let(:create_failed_path) { settings_iri_path(freetown, tab: :banners) }
  let(:updated_resource_path) { settings_iri_path(freetown, tab: :banners) }
  let(:update_failed_path) { edit_path }
  let(:invalid_create_params) { {banner: {audience: nil}} }
  let(:update_params) { {banner: {audience: 'guests'}} }
  let(:created_resource_path) { settings_iri_path(freetown, tab: :banners) }
  let(:create_differences) do
    subject
    {'Banner.count' => 1}
  end
  let(:update_differences) do
    subject
    {'Banner.count' => 0}
  end
  let(:destroy_differences) do
    subject
    {'Banner.count' => -1}
  end

  context 'with forum parent' do
    subject do
      create(:banner,
             audience: Banner.audiences[:everyone],
             forum: freetown,
             title: 'title',
             content: 'content')
    end
    it_behaves_like 'requests', skip: %i[delete trash untrash show delete index]
  end
end
