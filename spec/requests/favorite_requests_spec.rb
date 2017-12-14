# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Favorites', type: :request do
  include Argu::TestHelpers::AutomatedRequests

  let(:non_existing_create_path) { forum_favorites_path('non_existent') }
  let(:non_existing_destroy_path) { forum_favorites_path('non_existent') }
  let(:destroy_path) { forum_favorites_path(holland) }
  let(:update_failed_path) { url_for([holland, :favorites, only_path: true]) }
  let(:created_resource_path) { forum_path(holland) }
  let(:create_differences) { [['Favorite.count', 1]] }
  let(:destroy_differences) { [['Favorite.count', -1]] }
  let(:create_path) { url_for([holland, :favorites, only_path: true]) }
  let(:create_params) { {} }
  let(:authorized_user) { staff }
  let(:expect_delete_destroy_unauthorized_html) { expect_not_found }
  let(:expect_delete_destroy_unauthorized_serializer) { expect_not_found }

  subject { create(:favorite, user: staff, edge: holland.edge) }
  it_behaves_like 'post create', skip: %i[create_invalid]
  it_behaves_like 'delete destroy'
end
