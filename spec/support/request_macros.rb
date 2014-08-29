module RequestMacros
  include Devise::TestHelpers

  def login_user
    @user ||= FactoryGirl.create :user
    post_via_redirect user_session_path, 'user[login]' => @user.username, 'user[password]' => @user.password
  end

  def login_admin
    @user ||= FactoryGirl.create :administration
    post_via_redirect user_session_path, parameters = {'user[login]' => @user.username, 'user[password]' => @user.password}
  end
end