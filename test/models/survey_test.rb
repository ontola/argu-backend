# frozen_string_literal: true

require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:survey, parent: freetown) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
