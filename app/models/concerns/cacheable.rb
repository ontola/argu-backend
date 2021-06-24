# frozen_string_literal: true

module Cacheable
  include DeltaHelper

  def cacheable?
    true
  end
end
