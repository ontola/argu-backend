require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  let(:freetown) { FactoryGirl.create(:forum) }
  let(:capetown) { FactoryGirl.create(:forum, name: 'capetown') }
  subject { create_member(freetown).profile }

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

    assert subject.member_of?(freetown.id), 'false negative when forum_id is passed'
    assert_not subject.member_of?(capetown.id), 'false positive when forum_id is passed'
  end
end
