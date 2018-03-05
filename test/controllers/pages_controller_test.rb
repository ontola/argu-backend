# frozen_string_literal: true

require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  let!(:page1) { create(:page) }
  let!(:page2) { create(:page) }
  let!(:closed_page) { create(:page, visibility: Page.visibilities[:closed]) }
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
    expect_included(Page.open.map { |o| argu_url("/o/#{o.url}") })
    expect_not_included(argu_url("/o/#{closed_page.url}"))
    expect_not_included(argu_url("/o/#{hidden_page.url}"))
  end

  test 'should get index pages page 1' do
    get :index, params: {format: :json_api, page: 1}
    assert_response 200

    expect_relationship('partOf', 0)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count, 3
    expect_included(Page.open.map { |o| argu_url("/o/#{o.url}") })
    expect_not_included(argu_url("/o/#{closed_page.url}"))
    expect_not_included(argu_url("/o/#{hidden_page.url}"))
  end
end
