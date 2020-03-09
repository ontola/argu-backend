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
      sign_in :service

      get _public_spi_tenants_path

      assert_response 200
      assert_equal parsed_body['schemas'], %w[argu]
      sites = parsed_body['sites']
      assert_equal sites.length, 2
      assert_includes sites, 'name' => 'argu', 'location' => 'https://argu.localtest/argu'
      assert_includes sites, 'name' => 'argu', 'location' => 'https://argu.localtest/public_page'
    end

    test 'service should get tenant of iri' do
      sign_in :service

      get _public_spi_find_tenant_path(iri: argu.iri)

      assert_response 200
      assert_equal parsed_body, {
        uuid: argu.uuid,
        iri_prefix: 'argu.localtest/argu',
        accent_background_color: '#475668',
        accent_color: '#FFFFFF',
        navbar_background: '#475668',
        navbar_color: '#FFFFFF',
        database_schema: 'argu',
        use_new_frontend: false,
        display_name: 'Argu'
      }.as_json
    end
  end
end
