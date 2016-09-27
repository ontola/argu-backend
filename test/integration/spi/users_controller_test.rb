# frozen_string_literal: true
require 'test_helper'

module SPI
  class UsersControllerTest < ActionDispatch::IntegrationTest
    ####################################
    # As Guest
    ####################################
    test 'guest should not get show' do
      get spi_current_user_path

      assert_response 401
    end

    ####################################
    # As User
    ####################################
    let(:user) { create(:user) }

    test 'user should get show' do
      sign_in user

      get spi_current_user_path

      assert_response 200
    end
  end
end
