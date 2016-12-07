# frozen_string_literal: true
require 'test_helper'

class SourceTest < ActiveSupport::TestCase
  include ModelTestBase

  define_public_source
  let(:subject) { create(:source, parent: argu.edge, shortname: 'source') }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'should reset public grant' do
    assert_equal subject.grants.where(group_id: -1).count, 0
    subject.open!
    assert_equal subject.grants.where(group_id: -1).count, 1

    public_source.reset_public_grant
    assert_equal public_source.grants.where(group_id: -1).count, 1
    public_source.closed!
    assert_equal public_source.grants.where(group_id: -1).count, 0
  end
end
