# frozen_string_literal: true

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  define_freetown
  let(:capetown) { create_forum(name: 'capetown') }
  subject { create_member(freetown).profile }
  let(:managership) { create_manager(capetown.page, subject.profileable) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'shortname valid' do
    shortname = subject.profileable.shortname.shortname
    assert shortname.length > 3
    assert_equal shortname, subject.url
  end

  test 'display_name valid' do
    assert_equal "#{subject.profileable.first_name} #{subject.profileable.last_name}", subject.display_name
  end

  test 'member_of? function' do
    assert subject.member_of?(freetown), 'false negative when forum is passed'
    assert_not subject.member_of?(capetown), 'false positive when forum is passed'
  end

  test 'granted_edges' do
    capetown

    assert_equal subject.reload.granted_edges.pluck(:id).uniq, [freetown.edge.id]
    assert_equal subject.granted_edges(nil, :manager).pluck(:id), []
    managership
    assert_equal subject.reload.granted_edges.pluck(:id).uniq, [freetown.edge.id, capetown.page.edge.id]
    assert_equal subject.granted_edges(nil, :manager).pluck(:id).uniq, [capetown.page.edge.id]
  end
end
