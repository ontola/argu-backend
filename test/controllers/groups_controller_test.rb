require 'test_helper'

class GroupsControllerTest < Argu::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:forum, name: 'holland') }
  let!(:group) { FactoryGirl.create(:group, tenant: holland.name) }

  ####################################
  # For users
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should not show new', tenant: :holland do
    sign_in user

    get :new, id: group

    assert_redirected_to root_path
  end

  test 'should not show edit', tenant: :holland do
    sign_in user

    get :edit, id: group

    assert_redirected_to root_path
    assert assigns(:group)
  end

  test 'should not delete destroy', tenant: :holland do
    sign_in user

    assert_no_difference 'Group.count' do
      delete :destroy!, id: group
    end

    assert_redirected_to root_path
  end

  ####################################
  # For owners
  ####################################
  let(:owner) { make_owner(holland) }

  test 'should show new', tenant: :holland do
    sign_in owner

    get :new, id: group

    assert_response 200
    assert assigns(:group)
  end

  test 'should show edit', tenant: :holland do
    sign_in owner

    get :edit, id: group

    assert_response 200
    assert assigns(:group)
  end

  test 'should delete destroy!', tenant: :holland do
    sign_in owner

    assert_difference 'Group.count', -1 do
      delete :destroy!, id: group
    end

    assert_response 303
    assert assigns(:group)
  end
end
