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
        all_shortnames: %w[argu],
        database_schema: 'argu',
        display_name: 'Argu',
        header_background: 'background_primary',
        header_text: 'text_auto',
        language: 'en',
        iri_prefix: 'argu.localtest/argu',
        primary_color: '#475668',
        secondary_color: '#d96833',
        uuid: argu.uuid
      }.as_json
    end
  end
end
