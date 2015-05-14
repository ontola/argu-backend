require 'test_helper'

class PageTest < ActiveSupport::TestCase

  def page
    @page ||= pages(:page_argu)
  end

  def test_valid
    assert page.valid?, page.errors.to_a.join(',').to_s
  end

  test 'should invalidate policy not accepted' do
    assert_not pages(:not_accepted).valid?, 'Terms can be unaccepted'
  end

end
