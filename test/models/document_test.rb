# frozen_string_literal: true
require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  subject { create(:document_policy) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
