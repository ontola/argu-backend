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

  test 'granted_edges' do
    capetown

    assert_equal subject.reload.granted_edges.pluck(:id).uniq.sort,
                 ([freetown.id] + Vocabulary.pluck(:id)).uniq.sort
    assert_equal subject.granted_edges(owner_type: nil, grant_set: :moderator).pluck(:id), []
    moderator
    assert_equal subject.reload.granted_edges.pluck(:id).uniq.sort,
                 ([freetown.id, capetown.parent.id] + Vocabulary.pluck(:id)).uniq.sort
    assert_equal subject.granted_edges(owner_type: nil, grant_set: :moderator).pluck(:id).uniq,
                 [capetown.parent.id]
  end
end
