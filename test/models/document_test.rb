require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

  def document
    @documents ||= documents(:policy)
  end

  def test_valid
    assert document.valid?, document.errors.to_a.join(',').to_s
  end

end
