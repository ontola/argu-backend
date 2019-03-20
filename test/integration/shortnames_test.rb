# frozen_string_literal: true

require 'test_helper'

# Usual controller method tests
# Additionally tests for shortnames to be routed correctly between forums and dynamic redirects.
class ShortnamesTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  let(:argument) { create(:argument, parent: motion) }
  let(:comment) { create(:comment, parent: argument) }
  let(:publication) { build(:publication) }
  let(:comment_shortname) { create(:shortname, owner: comment) }
  let(:subject) do
    create(:discussion_shortname, owner: motion, primary: false, root_id: motion.root_id)
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should get forum' do
    get "/#{argu.url}/#{freetown.url}"

    assert_response 200
  end

  test 'guest should get resources' do
    parent = freetown
    %i[question motion argument].each do |klass|
      resource = create(klass, parent: parent)
      parent = resource

      shortname = create(:shortname, owner: resource)

      general_show(200, resource, shortname)
    end
  end

  test 'guest should get comment' do
    general_show(302, comment, comment_shortname) do
      assert_redirected_to comment.parent.iri(fragment: comment.identifier)
    end
  end

  ####################################
  # As Initiator
  ####################################
  let(:initiator) { create_initiator(freetown) }

  test 'initiator should not post create' do
    sign_in initiator
    general_create(response: 403, differences: {'Shortname.count' => 0})
    assert_not_authorized
  end

  test 'initiator should not delete destroy' do
    subject
    sign_in initiator
    general_destroy(response: 403)
  end

  ####################################
  # As Moderator
  ####################################
  let(:moderator) { create_moderator(freetown) }

  test 'moderator should not post create' do
    sign_in moderator
    general_create(response: 403, differences: {'Shortname.count' => 0})
    assert_not_authorized
  end

  test 'moderator should not delete destroy' do
    subject
    sign_in moderator
    general_destroy(response: 403)
  end

  ####################################
  # As Super admin
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should post create' do
    sign_in administrator
    general_create
  end

  test 'administrator should post create with url' do
    sign_in administrator
    general_create(attrs: {shortname: {shortname: 'short1', destination: "m/#{motion.fragment}"}})
    assert_equal Shortname.last.owner, motion
    assert_equal Shortname.last.root_id, argu.uuid
  end

  test 'administrator should not post create unscoped' do
    sign_in administrator
    general_create(attrs: {shortname: {shortname: 'short1', destination: "m/#{motion.fragment}", unscoped: true}})
    assert_equal Shortname.last.owner, motion
    assert_equal Shortname.last.root_id, argu.uuid
  end

  test 'administrator should delete destroy' do
    subject
    sign_in administrator
    general_destroy response: 303, difference: -1
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should post create unscoped' do
    sign_in staff
    general_create(attrs: {shortname: {shortname: 'short1', destination: "m/#{motion.fragment}", unscoped: true}})
    assert_equal Shortname.last.owner, motion
    assert_nil Shortname.last.root_id
  end

  private

  def general_show(response, resource, shortname)
    get "/#{shortname.shortname}"
    assert_redirected_to resource.iri.path
    follow_redirect!

    assert_response response

    yield if block_given?
  end

  def general_create(response: 302, differences: {'Shortname.count' => 1}, attrs: nil)
    attrs ||= shortname_attributes
    assert_difference(differences) do
      post collection_iri(argu, :shortnames), params: attrs
      assert_response response
    end
  end

  def general_destroy(response: 302, difference: 0)
    assert_difference('Shortname.count', difference) do
      delete resource_iri(subject)
      assert_response response
    end
  end

  # @return [Hash] Options to pass to the request
  def shortname_attributes
    attrs = attributes_for(:discussion_shortname, owner: motion)
    attrs.delete(:forum)
    owner = attrs.delete(:owner)
    attrs[:owner_id] = owner.owner_id
    attrs[:owner_type] = owner.owner_type
    {
      shortname: attrs
    }
  end
end
