# frozen_string_literal: true

require 'test_helper'

class ArgumentTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  subject { create(:pro_argument, parent: motion) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
