class StaticPagePolicy < Struct.new(:user, :static_pages)
  def home?
    true
  end

  def about?
    true
  end

  def product?
    @user && @user.profile.has_role?(:staff)
  end

  def sign_in_modal?
    true
  end

  def how_argu_works?
    true
  end

  def developers?
    user && user.profile.has_role?(:staff)
  end
end
