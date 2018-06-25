# frozen_string_literal: true

require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  let!(:page1) { create(:page) }
  let!(:page2) { create(:page) }
  let!(:hidden_page) { create(:page, visibility: Page.visibilities[:hidden]) }

  ####################################
  # Index
  ####################################
  test 'should get index pages' do
    get :index, params: {format: :json_api}
    assert_response 200

    expect_relationship('partOf', 0)

    expect_relationship('viewSequence', 1)
    expect_included(argu_url('/o', page: 1, type: 'paginated'))
    expect_included(Page.open.map(&:iri))
    expect_not_included(hidden_page.iri)
  end

  test 'should get index pages page 1' do
    get :index, params: {format: :json_api, page: 1}
    assert_response 200

    expect_relationship('partOf', 0)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count, 3
    expect_included(Page.open.map(&:iri))
    expect_not_included(hidden_page.iri)
  end
end
