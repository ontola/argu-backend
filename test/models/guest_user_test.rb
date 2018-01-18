# frozen_string_literal: true

require 'test_helper'
require 'argu/errors/no_persistence'

class GuestUserTest < ActiveSupport::TestCase
  subject { GuestUser.new(attributes_for(:user).merge(session: OpenStruct.new(id: 'session_id'))) }

  test 'should raise when saving GuestUser' do
    assert_raises Argu::Errors::NoPersistence do
      assert_no_difference('User.count') do
        subject.save
      end
    end
  end

  test 'should raise when creating GuestUser' do
    assert_raises Argu::Errors::NoPersistence do
      assert_no_difference('User.count') do
        GuestUser.create(attributes_for(:user).merge(session: OpenStruct.new(id: 'session_id')))
      end
    end
  end
end
