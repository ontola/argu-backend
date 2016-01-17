require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:access_token) }
  # :forum, :vwal is used here instead of :populated_forum_vwal
  # Since populated creates an access token making the
  # association explicitly set defeating the purpose of the test
  let(:venice) { FactoryGirl.create(:forum, :vwal) }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'association is properly set on forum' do
    assert_equal 'Forum', venice.full_access_token.item_type
    assert_equal venice.id, venice.full_access_token.item_id
  end

end
