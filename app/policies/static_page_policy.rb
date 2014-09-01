class StaticPagePolicy < Struct.new(:user, :static_pages)
  def home?
    true
  end

  def about?
    true
  end
end
