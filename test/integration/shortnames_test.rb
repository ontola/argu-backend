# frozen_string_literal: true
require 'test_helper'

# Tests shortnames to be routed correctly between forums and dynamic redirects.
class ShortnamesTest < ActionDispatch::IntegrationTest
  let!(:freetown) { create(:forum, name: 'freetown') }
  let(:comment) { create(:comment, forum: freetown) }
  let(:comment_shortname) { create(:shortname, owner: comment) }

  ####################################
  # As Guest
  ####################################
  test 'guest should get forum' do
    get "/#{freetown.url}"

    assert_response 200
  end

  %i(published_project question motion argument).each do |resource|
    let(resource) { create(resource, forum: freetown) }
    let("#{resource}_shortname".to_sym) { create(:shortname, owner: send(resource)) }


    test "guest should get #{resource}" do
      general_show(200, send(resource), send("#{resource}_shortname"))
    end
  end

  test 'guest should get comment' do
    general_show(302, comment, comment_shortname) do
      assert_redirected_to argument_path(comment.commentable, anchor: comment.identifier)
    end
  end

  private

  def general_show(response, resource, shortname)
    get url_for("/#{shortname.shortname}")
    assert_redirected_to url_for(resource)
    follow_redirect!

    assert_response response

    yield if block_given?
  end
end
