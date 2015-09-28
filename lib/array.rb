
class Array
  def extract(&block)
    items = []
    self.each_index do |i|
      r = block.call(self[i])
      items << self.pop(i) if r
    end
    items
  end
end
