# frozen_string_literal: true

require 'test_helper'

class GuestUserTest < ActiveSupport::TestCase
  subject { GuestUser.new(attributes_for(:user)) }

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
        GuestUser.create(attributes_for(:user))
      end
    end
  end
end
