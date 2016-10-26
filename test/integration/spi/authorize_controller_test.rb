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
  end
end
