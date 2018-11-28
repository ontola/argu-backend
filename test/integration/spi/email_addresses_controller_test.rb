# frozen_string_literal: true

require 'test_helper'

module SPI
  class EmailAddressesControllerTest < ActionDispatch::IntegrationTest
    let(:user) { create(:user) }

    test 'service should get existing email' do
      sign_in :service

      get spi_email_addresses_path, params: {email: user.email}

      assert_response 200
    end

    test 'service should not get wrong email' do
      sign_in :service

      get spi_email_addresses_path, params: {email: 'wrong@example.com'}

      assert_response 404
    end
  end
end
