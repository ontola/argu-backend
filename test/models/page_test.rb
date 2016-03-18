require 'test_helper'

class PageTest < ActiveSupport::TestCase
  subject do
    create(:page,
           profile: create(:profile,
                           name: 'test'))
  end

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'should invalidate policy not accepted' do
    begin
      page = create(:page, last_accepted: nil)
    rescue ActiveRecord::RecordInvalid
      assert true
    else
      assert_not true, 'Terms can be unaccepted'
    ensure
      assert_nil page
    end
  end
end
