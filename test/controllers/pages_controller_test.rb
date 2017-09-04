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

    expect_relationship('parent', 0)
    expect_relationship('members', 0)

    expect_relationship('views', 1)
    expect_included(argu_url('/o', page: 1))
    expect_included(Page.open.map { |o| argu_url("/o/#{o.id}") })
    expect_not_included(argu_url("/o/#{closed_page.id}"))
    expect_not_included(argu_url("/o/#{hidden_page.id}"))
  end

  test 'should get index pages page 1' do
    get :index, params: {format: :json_api, page: 1}
    assert_response 200

    expect_relationship('parent', 0)
    expect_relationship('views', 0)

    expect_relationship('members', 3)
    expect_included(Page.open.map { |o| argu_url("/o/#{o.id}") })
    expect_not_included(argu_url("/o/#{closed_page.id}"))
    expect_not_included(argu_url("/o/#{hidden_page.id}"))
  end
end
