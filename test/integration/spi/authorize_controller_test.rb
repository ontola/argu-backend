# frozen_string_literal: true
require 'test_helper'

module SPI
  class AuthorizeControllerTest < ActionDispatch::IntegrationTest
    define_freetown
    let(:motion) { create(:motion, publisher: creator, parent: freetown.edge) }

    ####################################
    # As Guest
    ####################################
    test 'guest should show motion' do
      get spi_authorize_path(resource_type: 'Motion', resource_id: motion.id, authorize_action: 'show')

      assert_response 200
    end

    test 'guest should not update motion' do
      get spi_authorize_path(resource_type: 'Motion', resource_id: motion.id, authorize_action: 'update')

      assert_response 403
    end

    test 'guest should not show page actor' do
      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: freetown.page.profile.id, authorize_action: 'show'
      )

      assert_response 403
    end

    test 'guest should not show page actor as iri' do
      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: freetown.page.context_id, authorize_action: 'show'
      )

      assert_response 403
    end

    test 'guest should not show user actor' do
      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: user.profile.id, authorize_action: 'show'
      )

      assert_response 403
    end

    test 'guest should not show user actor as iri' do
      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: user.context_id, authorize_action: 'show'
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
        resource_type: 'CurrentActor', resource_id: freetown.page.profile.id, authorize_action: 'show'
      )

      assert_response 403
    end

    test 'user should not show page actor as iri' do
      sign_in user

      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: freetown.page.context_id, authorize_action: 'show'
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

      get spi_authorize_path(resource_type: 'CurrentActor', resource_id: user.context_id, authorize_action: 'show')

      assert_response 200
    end

    test 'user should not is_member managers group' do
      sign_in user

      get spi_authorize_path(
        resource_type: 'Group',
        resource_id: freetown.page.grants.manager.first.group,
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
    # As Manager
    ####################################
    let(:manager) { create_manager(freetown.page) }

    test 'manager should show page actor' do
      sign_in manager

      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: freetown.page.profile.id, authorize_action: 'show'
      )

      assert_response 200
    end

    test 'manager should show page actor as iri' do
      sign_in manager

      get spi_authorize_path(
        resource_type: 'CurrentActor', resource_id: freetown.page.context_id, authorize_action: 'show'
      )

      assert_response 200
    end

    test 'manager should not show user actor' do
      sign_in manager

      get spi_authorize_path(resource_type: 'CurrentActor', resource_id: user.profile.id, authorize_action: 'show')

      assert_response 403
    end

    test 'manager should not show user actor as iri' do
      sign_in manager

      get spi_authorize_path(resource_type: 'CurrentActor', resource_id: user.context_id, authorize_action: 'show')

      assert_response 403
    end

    test 'manager should is_member managers group' do
      sign_in manager

      get spi_authorize_path(
        resource_type: 'Group',
        resource_id: freetown.page.grants.manager.first.group,
        authorize_action: 'is_member'
      )

      assert_response 200
    end
  end
end
