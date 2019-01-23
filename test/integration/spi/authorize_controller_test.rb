# frozen_string_literal: true

require 'test_helper'

module SPI
  class AuthorizeControllerTest < ActionDispatch::IntegrationTest
    define_freetown
    let(:guest_user) { create_guest_user }
    let(:motion) { create(:motion, publisher: creator, parent: freetown) }

    ####################################
    # As Guest
    ####################################
    test 'guest should show motion' do
      sign_in guest_user

      get spi_authorize_path(resource_type: 'Motion', resource_id: motion.id, authorize_action: 'show')

      assert_response 200
    end

    test 'guest should show motion as iri' do
      sign_in guest_user

      get spi_authorize_path(resource_iri: resource_iri(motion), authorize_action: 'show')

      assert_response 200
    end

    test 'guest should show motion as canonical' do
      sign_in guest_user

      get spi_authorize_path(resource_iri: motion.canonical_iri, authorize_action: 'show')

      assert_response 200
    end

    test 'guest should not show non-existing motion' do
      sign_in guest_user

      get spi_authorize_path(resource_type: 'Motion', resource_id: 'non-existing', authorize_action: 'show')

      assert_response 404
    end

    test 'guest should not show non-existing motion as iri' do
      sign_in guest_user

      get spi_authorize_path(
        resource_iri: expand_uri_template(:motions_iri, id: 'non-existing', with_hostname: true),
        authorize_action: 'show'
      )

      assert_response 404
    end

    test 'guest should not show non-existing motion as canonical' do
      sign_in guest_user

      get spi_authorize_path(
        resource_iri: expand_uri_template(:edges_iri, id: SecureRandom.uuid, with_hostname: true),
        authorize_action: 'show'
      )

      assert_response 404
    end

    test 'guest should not update motion' do
      sign_in guest_user

      get spi_authorize_path(resource_type: 'Motion', resource_id: motion.id, authorize_action: 'update')

      assert_response 403
    end

    test 'guest should not update motion as iri' do
      sign_in guest_user

      get spi_authorize_path(resource_iri: resource_iri(motion), authorize_action: 'update')

      assert_response 403
    end

    test 'guest should not update motion as canonical' do
      sign_in guest_user

      get spi_authorize_path(resource_iri: motion.canonical_iri, authorize_action: 'update')

      assert_response 403
    end

    test 'guest should not show page actor' do
      sign_in guest_user

      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: argu.profile.id, authorize_action: 'show'
      )

      assert_response 403
    end

    test 'guest should not show page actor as iri' do
      sign_in guest_user

      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: resource_iri(argu), authorize_action: 'show'
      )

      assert_response 403
    end

    test 'guest should not show user actor' do
      sign_in guest_user

      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: user.profile.id, authorize_action: 'show'
      )

      assert_response 403
    end

    test 'guest should not show user actor as iri' do
      sign_in guest_user

      get spi_authorize_path(
        resource_type: 'CurrentActor',
        resource_id: resource_iri(user, root: argu),
        authorize_action: 'show'
      )

      assert_response 403
    end

    ####################################
    # As User
    ####################################
    let(:user) { create(:user) }

    test 'user should show motion' do
      sign_in user

      get spi_authorize_path(resource_type: 'Motion', resource_id: motion.id, authorize_action: 'show')

      assert_response 200
    end

    test 'user should not update motion' do
      sign_in user

      get spi_authorize_path(resource_type: 'Motion', resource_id: motion.id, authorize_action: 'update')

      assert_response 403
    end

    test 'user should not show page actor' do
      sign_in user

      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: argu.profile.id, authorize_action: 'show'
      )

      assert_response 403
    end

    test 'user should not show page actor as iri' do
      sign_in user

      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: resource_iri(argu), authorize_action: 'show'
      )

      assert_response 403
    end

    test 'user should show user actor' do
      sign_in user

      get spi_authorize_path(resource_type: 'CurrentActor', resource_id: user.profile.id, authorize_action: 'show')

      assert_response 200
    end

    test 'user should show user actor as iri' do
      sign_in user

      get spi_authorize_path(
        resource_type: 'CurrentActor',
        resource_id: resource_iri(user, root: argu),
        authorize_action: 'show'
      )

      assert_response 200
    end

    test 'user should not is_member administrators group' do
      sign_in user

      get spi_authorize_path(
        resource_type: 'Group',
        resource_id: argu.grants.administrator.first.group,
        authorize_action: 'is_member'
      )

      assert_response 403
    end

    ####################################
    # As Creator
    ####################################
    let(:creator) { create(:user) }

    test 'creator should show motion' do
      sign_in creator

      get spi_authorize_path(resource_type: 'Motion', resource_id: motion.id, authorize_action: 'show')

      assert_response 200
    end

    test 'creator should update motion' do
      sign_in creator

      get spi_authorize_path(resource_type: 'Motion', resource_id: motion.id, authorize_action: 'update')

      assert_response 200
    end

    ####################################
    # As Administrator
    ####################################
    let(:administrator) { create_administrator(argu) }

    test 'administrator should show page actor' do
      sign_in administrator

      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: argu.profile.id, authorize_action: 'show'
      )

      assert_response 200
    end

    test 'administrator should show page actor as iri' do
      sign_in administrator

      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: resource_iri(argu), authorize_action: 'show'
      )

      assert_response 200
    end

    test 'administrator should not show user actor' do
      sign_in administrator

      get spi_authorize_path(resource_type: 'CurrentActor', resource_id: user.profile.id, authorize_action: 'show')

      assert_response 403
    end

    test 'administrator should not show user actor as iri' do
      sign_in administrator

      get spi_authorize_path(
        resource_type: 'CurrentActor',
        resource_id: resource_iri(user, root: argu),
        authorize_action: 'show'
      )

      assert_response 403
    end

    test 'administrator should group_member administrators group' do
      sign_in administrator

      get spi_authorize_path(
        resource_type: 'Group',
        resource_id: argu.grants.administrator.first.group,
        authorize_action: 'is_member'
      )

      assert_response 200
    end
  end
end
