# frozen_string_literal: true
require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:question, parent: freetown.edge) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
