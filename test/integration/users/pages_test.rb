# frozen_string_literal: true

require 'test_helper'

module Users
  class PagesTest < ActionDispatch::IntegrationTest
    define_freetown
    let!(:other_page) { create_page }

    ####################################
    # As Guest
    ####################################
    test 'guest should not get index of user' do
      sign_in :guest_user

      get user.collection_iri(:favorite_pages, root: other_page)

      assert_not_authorized
    end

    ####################################
    # As User
    ####################################
    let(:user) { create(:user) }

    test 'user should get index' do
      sign_in user

      get user.collection_iri(:favorite_pages, root: other_page)
      assert_response :success
      expect_triple(requested_iri, NS.as[:totalItems], 1)
    end

    ####################################
    # As Administrator
    ####################################
    let(:administrator) { create_administrator(freetown) }

    test 'administrator should get index' do
      sign_in administrator

      get administrator.collection_iri(:favorite_pages, root: other_page)
      assert_response :success
      expect_triple(requested_iri, NS.as[:totalItems], 2)
    end

    test 'administrator should not get index of other user' do
      sign_in administrator

      get user.collection_iri(:favorite_pages, root: other_page)
      assert_response :forbidden
    end
  end
end
