# frozen_string_literal: true

require 'test_helper'

module SPI
  class TenantsControllerTest < ActionDispatch::IntegrationTest
    define_page
    let(:user) { create(:user) }

    after do
      Apartment::Tenant.switch! 'argu'
    end

    test 'service should get index' do
      sign_in :service, Doorkeeper::Application.argu_front_end

      get _public_spi_tenants_path

      assert_response 200
      assert_equal parsed_body, 'schemas' => %w[argu]
    end
  end
end
