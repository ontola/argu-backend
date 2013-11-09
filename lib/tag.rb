
ActsAsTaggableOn::Tag.class_eval do
  has_one :statement
  puts "================================================"
  def ftest
    puts "test!"
  end
end