# frozen_string_literal: true

require 'test_helper'

class PageTest < ActiveSupport::TestCase
  subject { create_page(profile: build(:profile, name: 'test')) }
  define_freetown

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'should invalidate policy not accepted' do
    page = Page.create!(attributes_for(:page, last_accepted: nil))
    assert_not true, 'Terms can be unaccepted'
  rescue ActiveRecord::RecordInvalid => e
    assert e.message.include?("Last accepted can't be blank")
  ensure
    assert_nil page
  end

  test 'should reset primary container node' do
    assert_nil argu.primary_container_node
    argu.update(primary_container_node: freetown)
    assert_equal argu.reload.primary_container_node, freetown
    assert_equal argu.reload.primary_container_node_id, freetown.uuid
    freetown.destroy!
    assert_nil argu.reload.primary_container_node_id
    assert_nil argu.reload.primary_container_node
  end
end
