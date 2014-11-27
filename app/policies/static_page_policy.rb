class StaticPagePolicy < Struct.new(:user, :static_pages)
  def home?
    true
  end

  def about?
    true
  end

  def sign_in_modal?
    true
  end

  def developers?
    user && user.profile.has_role?(:staff)
  end
end
