# frozen_string_literal: true

require 'test_helper'

class PageTest < ActiveSupport::TestCase
  subject { create_page(profile: build(:profile, name: 'test')) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'should invalidate policy not accepted' do
    begin
      page = Page.create!(attributes_for(:page, last_accepted: nil))
    rescue ActiveRecord::RecordInvalid => e
      assert e.message.include?("Last accepted can't be blank")
    else
      assert_not true, 'Terms can be unaccepted'
    ensure
      assert_nil page
    end
  end
end
