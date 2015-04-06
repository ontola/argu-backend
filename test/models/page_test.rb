require 'test_helper'

class PageTest < ActiveSupport::TestCase

  def page
    @page ||= pages(:argu)
  end

  def test_valid
    assert page.valid?, page.errors.to_a.join(',').to_s
  end

end
