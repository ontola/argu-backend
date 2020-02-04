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

      get collection_iri(user, :pages, root: other_page)

      assert_not_a_user
    end

    ####################################
    # As User
    ####################################
    let(:user) { create(:user) }

    test 'user should get index' do
      sign_in user

      get collection_iri(user, :pages, root: other_page)
      assert_response :success
      expect_triple(requested_iri, NS::AS[:totalItems], 0)
    end

    ####################################
    # As Administrator
    ####################################
    let(:administrator) { create_administrator(freetown) }

    test 'administrator should get index' do
      sign_in administrator

      get collection_iri(administrator, :pages, root: other_page)
      assert_response :success
      expect_triple(requested_iri, NS::AS[:totalItems], 1)
    end

    test 'administrator should not get index of other user' do
      sign_in administrator

      get collection_iri(user, :pages, root: other_page)
      assert_response :success
      refute_includes(response.body, requested_iri)
    end
  end
end
