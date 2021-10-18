# frozen_string_literal: true

require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  define_freetown
  let!(:group) { create(:group, parent: argu) }
  let(:administrator) { create_administrator(argu) }

  ####################################
  # Show
  ####################################
  test 'should get show' do
    sign_in administrator
    get :show, params: {format: :json_api, id: group.id}
    assert_response 200
  end

  ####################################
  # Index
  ####################################
  test 'should get index groups' do
    sign_in administrator
    get :index, params: {format: :json_api}
    assert_response 200

    expect_included(Group.collection_iri(root: argu, page: 1))
  end
end
