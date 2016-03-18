require 'test_helper'

class PagesIntegrationTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  let(:page) { create(:page) }

  test 'should redirect p to o' do
    get "/p/#{page.url}"

    assert_redirected_to page_url(page)
    assert_redirected_to "/o/#{page.url}"
  end

end
