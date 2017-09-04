# frozen_string_literal: true

class Array
  def extract
    items = []
    each_index do |i|
      r = yield self[i]
      items << pop(i) if r
    end
    items
  end
end
