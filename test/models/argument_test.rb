# frozen_string_literal: true

require 'test_helper'

class ArgumentTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  subject { create(:argument, parent: motion.edge) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
