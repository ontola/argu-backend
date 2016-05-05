# frozen_string_literal: true
require 'test_helper'

# Usual controller method tests
# Additionally tests for shortnames to be routed correctly between forums and dynamic redirects.
class ShortnamesControllerTest < ActionDispatch::IntegrationTest
  let!(:freetown) { create(:forum, name: 'freetown', max_shortname_count: 1) }
  let(:comment) { create(:comment, forum: freetown) }
  let(:comment_shortname) { create(:shortname, owner: comment) }
  let(:subject) do
    create(:discussion_shortname,
           forum: freetown)
  end

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

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should not post create' do
    sign_in member
    general_create(302, [['Shortname.count', 0]])
    assert_not_authorized
  end

  test 'member should not put update' do
    sign_in member
    general_update
  end

  test 'member should not delete destroy' do
    subject
    sign_in member
    general_destroy
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(freetown) }

  test 'manager should post create' do
    sign_in manager
    general_create
  end

  test 'manager post create should not overflow limit' do
    create(:discussion_shortname, forum: freetown)
    assert freetown.max_shortname_count, freetown.shortnames.count
    sign_in manager
    general_create 302, [['Shortname.count', 0]]
  end

  test 'manager should put update' do
    sign_in manager
    general_update 302, true
  end

  test 'manager should delete destroy' do
    subject
    sign_in manager
    general_destroy 302, -1
  end

  private

  def general_show(response, resource, shortname)
    get url_for("/#{shortname.shortname}")
    assert_redirected_to url_for(resource)
    follow_redirect!

    assert_response response

    yield if block_given?
  end

  def general_create(response = 302, differences = [['Shortname.count', 1]])
    attrs = shortname_attributes
    assert_differences(differences) do
      post forum_shortnames_path(freetown, attrs)
      assert_response response
    end
  end

  def general_update(response = 302, changed = false)
    ch_method = method(changed ? :assert_not_equal : :assert_equal)
    put shortname_path(subject, shortname_attributes)
    assert_response response
    ch_method.call subject
                     .updated_at
                     .utc
                     .iso8601(6),
                   assigns(:shortname)
                     .updated_at
                     .utc
                     .iso8601(6)
  end

  def general_destroy(response = 302, difference = 0)
    assert_difference('Shortname.count', difference) do
      delete shortname_path(subject)
      assert_response response
    end
  end

  # @return [Hash] Options to pass to the request
  def shortname_attributes
    attrs = attributes_for(:discussion_shortname,
                           forum: freetown)
    attrs.delete(:forum)
    owner = attrs.delete(:owner)
    attrs[:owner_id] = owner.id
    attrs[:owner_type] = owner.model_name.to_s
    {
      shortname: attrs
    }
  end
end
