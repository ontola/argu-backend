# frozen_string_literal: true

require 'test_helper'

class GrantSetsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:staff) { create(:user, :staff) }

  test 'guest get show grant_set' do
    sign_in :guest_user

    get grant_set_path('participator')
    assert 200
  end

  test 'user get show grant_set' do
    sign_in user
    get grant_set_path('participator')
    assert 200
  end

  test 'staff get show grant_set' do
    sign_in staff
    %w[spectator participator initiator moderator administrator staff].each do |title|
      get grant_set_path(title)
    end
    assert 200
  end

  private

  def grant_set_path(*args)
    "#{argu.iri}#{super}"
  end
end
