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

    expect_no_relationship('partOf')

    expect_default_view
    expect_included(argu_url('/o', page: 1, type: 'paginated'))
    expect_included(Page.visible.map(&:iri))
    expect_not_included(hidden_page.iri)
  end

  test 'should get index pages page 1' do
    get :index, params: {format: :json_api, type: 'paginated', page: 1}
    assert_response 200

    expect_no_relationship('partOf')

    expect_view_members(primary_resource, 3)
    expect_included(Page.visible.map(&:iri))
    expect_not_included(hidden_page.iri)
  end
end
