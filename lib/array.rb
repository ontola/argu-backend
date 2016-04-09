
class Array
  def extract(&block)
    items = []
    each_index do |i|
      r = yield self[i]
      items << pop(i) if r
    end
    items
  end
end
