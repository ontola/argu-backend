require 'test_helper'

class CommentsTest < ActionDispatch::IntegrationTest
  let!(:venice) { create(:forum, :vwal) }
  let(:access_token) { create(:access_token, item: venice) }

  ####################################
  # Not logged in
  ####################################

  ####################################
  # As user
  ####################################
  let(:user) { create(:user) }

  test 'should post create a comment' do
    nominatim_netherlands

    get forum_path(venice.url,
                   at: access_token.access_token)
    assert_response :success

    post forum_memberships_path(venice.url,
                                r: forum_path(venice.url),
                                at: access_token.access_token)
    assert_redirected_to new_user_session_path(r: forum_path(venice.url))
    assert assigns(:resource)

    follow_redirect!

    assert_differences [['User.count', 1],
                        ['Sidekiq::Worker.jobs.size', 1]] do
      post user_registration_path,
           {user: {
             shortname_attributes: {shortname: 'newuser'},
             email: 'newuser@example.com',
             password: 'useruser',
             password_confirmation: 'useruser',
             r: venice.url
           },
           at: access_token.access_token}
    end
    assert_redirected_to edit_user_url('newuser')
    follow_redirect!

    put profile_path('newuser'),
        {profile: {
          profileable_attributes: {
            first_name: 'new',
            last_name: 'user'
          },
          about: 'Something ab'
        }}
    assert_redirected_to forum_url(venice.url)
    assert assigns(:resource)
    assert assigns(:profile)
    assert_equal 1, assigns(:profile).memberships.count
  end
end
