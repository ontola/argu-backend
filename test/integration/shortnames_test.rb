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
      assert_redirected_to comment.parent.iri_path(fragment: comment.identifier)
    end
  end

  ####################################
  # As Initiator
  ####################################
  let(:initiator) { create_initiator(freetown) }

  test 'initiator should not post create' do
    sign_in initiator
    general_create(403, 'Shortname.count' => 0)
    assert_not_authorized
  end

  test 'initiator should not put update' do
    sign_in initiator
    general_update(403)
  end

  test 'initiator should not delete destroy' do
    subject
    sign_in initiator
    general_destroy(403)
  end

  ####################################
  # As Moderator
  ####################################
  let(:moderator) { create_moderator(freetown) }

  test 'moderator should not post create' do
    sign_in moderator
    general_create(403, 'Shortname.count' => 0)
    assert_not_authorized
  end

  test 'moderator should not put update' do
    sign_in moderator
    general_update(403)
  end

  test 'moderator should not delete destroy' do
    subject
    sign_in moderator
    general_destroy(403)
  end

  ####################################
  # As Super admin
  ####################################
  let(:administrator) { create_administrator(freetown) }

  test 'administrator should post create' do
    sign_in administrator
    general_create
  end

  test 'administrator should put update' do
    sign_in administrator
    general_update 302, true
  end

  test 'administrator should delete destroy' do
    subject
    sign_in administrator
    general_destroy 303, -1
  end

  private

  def general_show(response, resource, shortname)
    get "/#{shortname.shortname}"
    assert_redirected_to resource.iri_path
    follow_redirect!

    assert_response response

    yield if block_given?
  end

  def general_create(response = 302, differences = {'Shortname.count' => 1})
    attrs = shortname_attributes
    assert_difference(differences) do
      post collection_iri_path(argu, :shortnames), params: attrs
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
                   assigns(:resource)
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
