require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  define_freetown

  ####################################
  # As Guest
  ####################################
  let(:user) { create(:user) }
  let(:user_non_public) { create(:user, profile: create(:profile, is_public: false)) }
  let(:user_hidden_votes) { create(:user, profile: create(:profile, are_votes_public: false)) }

  test 'guest should get show when public' do
    get :show, id: user

    assert_response 200
  end

  test 'guest should not get show when not public' do
    get :show, id: user_non_public

    assert_redirected_to root_path
    assert_nil assigns(:collection)
  end

  test 'guest should get show with platform access' do
    initialize_user2_votes
    get :show,
        id: user2,
        at: create(:access_token)

    assert_response 200
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    assert assigns(:collection).values.all? { |arr| arr[:collection].all? { |v| v.forum.open? } },
           'Votes of closed fora are visible to non-members'
  end

  test 'guest should put language' do
    request.env['HTTP_REFERER'] = root_url
    assert_nil cookies['locale']
    put :language, locale: :en
    assert_equal 'en', cookies['locale']
  end

  ####################################
  # As User
  ####################################
  let(:other_user) { create(:user) }

  test 'user should get show non public' do
    sign_in user

    get :show, id: user_non_public

    assert_response 200
  end

  let(:amsterdam) { create_forum }
  let(:utrecht) { create_forum }
  let(:user2) { create_member(amsterdam, create_member(utrecht)) }

  test 'user should get show' do
    initialize_user2_votes
    sign_in user

    get :show, id: user2

    assert_response 200
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    _memberships = assigns(:current_profile).memberships.for_forums.pluck('edges.owner_id')
    assert assigns(:collection)
             .values
             .all? { |arr| arr[:collection].all? { |v| _memberships.include?(v.forum_id) || v.forum.open? } },
           'Votes of closed fora are visible to non-members'
  end

  test 'user should not show all votes' do
    sign_in initialize_user2_votes

    get :show, id: user2
    assert_response 200
    assert assigns(:collection)

    assert_not assigns(:collection)[:con][:collection].any?, 'all votes are shown'
    assert_equal user2
                   .profile
                   .votes_questions_motions
                   .reject(&:is_trashed?)
                   .length,
                 assigns(:collection)
                   .values
                   .map {|i| i[:collection].length }.inject(&:+),
                 'Not all/too many votes are shown'
  end

  test 'user should not show votes when not votes are hidden' do
    sign_in user

    get :show, id: user_hidden_votes
    assert_response 200
    assert_not assigns(:collection)
  end

  test 'user should show votes when viewing own profile' do
    sign_in user_hidden_votes

    get :show, id: user_hidden_votes
    assert_response 200
    assert assigns(:collection)
  end

  test 'user should not show votes of trashed objects' do
    sign_in user2

    get :show, id: initialize_user2_votes

    assert_response 200
    assert assigns(:collection)[:pro][:collection].length > 0
    assert_not assigns(:collection)[:pro][:collection].any? { |v| v.voteable.is_trashed? }
  end

  test 'user should put language' do
    user = create_member(utrecht, create_member(amsterdam))
    sign_in user
    request.env['HTTP_REFERER'] = root_url
    assert_equal 'en', user.language
    put :language, locale: :nl
    assert_equal 'nl', user.reload.language
    assert_nil flash[:error]
  end

  test 'user should not put non-existing language' do
    user = create_member(utrecht, create_member(amsterdam))
    sign_in user
    request.env['HTTP_REFERER'] = root_url
    assert_equal 'en', user.language
    put :language, locale: :fake_language
    assert_equal 'en', user.reload.language
    assert flash[:error].present?
  end

  private

  def initialize_user2_votes
    motion1 = create(:motion, parent: utrecht.edge)
    motion3 = create(:motion, parent: amsterdam.edge, creator: user2.profile)
    motion4 = create(:motion, parent: freetown.edge, creator: user2.profile, is_trashed: true)
    argument1 = create(:argument, parent: motion1.edge)
    create(:vote, for: :neutral, parent: motion1.edge, voter: user2.profile, publisher: user2)
    create(:vote, for: :pro, parent: motion3.edge, voter: user2.profile, publisher: user2)
    create(:vote, for: :neutral, parent: argument1.edge, voter: user2.profile, publisher: user2)
    create(:vote, for: :pro, parent: motion4.edge, voter: user2.profile, publisher: user2)
    user2
  end
end
