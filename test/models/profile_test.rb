# frozen_string_literal: true

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  define_freetown
  let(:capetown) { create_forum(name: 'capetown') }
  subject { create_initiator(freetown).profile }
  let(:moderator) { create_moderator(capetown.root, subject.profileable) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'shortname valid' do
    shortname = subject.profileable.shortname.shortname
    assert shortname.length > 3
    assert_equal shortname, subject.url
  end

  test 'granted_edges' do
    capetown

    assert_equal subject.reload.granted_edges.pluck(:id).uniq, [freetown.id]
    assert_equal subject.granted_edges(owner_type: nil, grant_set: :moderator).pluck(:id), []
    moderator
    assert_equal subject.reload.granted_edges.pluck(:id).uniq.sort, [freetown.id, capetown.parent.id].sort
    assert_equal subject.granted_edges(owner_type: nil, grant_set: :moderator).pluck(:id).uniq,
                 [capetown.parent.id]
  end
end
