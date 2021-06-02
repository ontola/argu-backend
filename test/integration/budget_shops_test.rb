# frozen_string_literal: true

require 'test_helper'

class BudgetShopsTest < ActionDispatch::IntegrationTest
  define_freetown
  subject { create(:budget_shop, parent: freetown) }
  let(:user) { create(:user) }
  let(:administrator) { create_administrator(freetown) }

  ####################################
  # As Guest
  ####################################
  test 'guest should get show' do
    sign_in :guest_user

    general_show(results: {response: :success})
  end

  test 'guest should not get new' do
    sign_in :guest_user

    general_new(parent: freetown, results: {should: false})
  end

  test 'guest should not post create' do
    sign_in :guest_user

    general_create(parent: freetown, results: {response: :unauthorized, should: false})
  end

  test 'guest should not get edit' do
    sign_in :guest_user

    general_edit(results: {should: false})
  end

  test 'guest should not put update' do
    sign_in :guest_user

    general_update(results: {response: :unauthorized, should: false})
  end

  test 'guest should not get delete' do
    sign_in :guest_user

    general_delete(results: {should: false})
  end

  test 'guest should not delete destroy' do
    sign_in :guest_user

    general_destroy(results: {response: :unauthorized, should: false})
  end

  ####################################
  # As User
  ####################################
  test 'user should get show' do
    sign_in user

    general_show(results: {response: :success})
  end

  test 'user should not get new' do
    sign_in user

    general_new(parent: freetown, results: {should: false})
  end

  test 'user should not post create' do
    sign_in user

    general_create(parent: freetown, results: {response: :forbidden, should: false})
  end

  test 'user should not get edit' do
    sign_in user

    general_edit(results: {should: false})
  end

  test 'user should not put update' do
    sign_in user

    general_update(results: {response: :forbidden, should: false})
  end

  test 'user should not get delete' do
    sign_in user

    general_delete(results: {should: false})
  end

  test 'user should not delete destroy' do
    sign_in user

    general_destroy(results: {response: :forbidden, should: false})
  end

  ####################################
  # As Administrator
  ####################################
  test 'administrator should get show' do
    sign_in administrator

    general_show(results: {response: :success})
  end

  test 'administrator should get new' do
    sign_in administrator

    general_new(parent: freetown, results: {should: true})
  end

  test 'administrator should post create' do
    sign_in administrator

    general_create(parent: freetown, results: {response: :success, should: true})
  end

  test 'administrator should get edit' do
    sign_in administrator

    general_edit(results: {should: true})
  end

  test 'administrator should put update' do
    sign_in administrator

    general_update(results: {response: :success, should: true})
  end

  test 'administrator should get delete' do
    sign_in administrator

    general_delete(results: {should: true})
  end

  test 'administrator should delete destroy' do
    sign_in administrator

    general_destroy(results: {response: :success, should: true})
  end
end
