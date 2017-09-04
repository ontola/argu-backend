# frozen_string_literal: true

require 'test_helper'
require 'argu/no_persistence_error'

class GuestUserTest < ActiveSupport::TestCase
  subject { GuestUser.new(attributes_for(:user).merge(session: OpenStruct.new(id: 'session_id'))) }

  test 'should raise when saving GuestUser' do
    assert_raises Argu::NoPersistenceError do
      assert_no_difference('User.count') do
        subject.save
      end
    end
  end

  test 'should raise when creating GuestUser' do
    assert_raises Argu::NoPersistenceError do
      assert_no_difference('User.count') do
        GuestUser.create(attributes_for(:user).merge(session: OpenStruct.new(id: 'session_id')))
      end
    end
  end
end
