require 'test_helper'

module Portal
  class AnnouncementsControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    subject do
      create(:announcement,
             :everyone)
    end
    let!(:holland) do
      create(:populated_forum,
             name: 'holland')
    end
    let!(:holland_owner) { create(:user) }

    ####################################
    # Shared
    ####################################

    def general_new(response = 302)
      get :new,
          forum_id: holland

      assert_response response
    end

    def general_create(response = 302, differences = [['Announcement.count', 0]])
      assert_differences(differences) do
        post :create,
             announcement: attributes_for(:announcement)
      end

      assert_response response
    end

    def general_edit(response = 302)
      get :edit,
          id: subject

      assert_response response
    end

    def general_update(response = 302, changed = false)
      ch_method = method(changed ? :assert_not_equal : :assert_equal)

      patch :update,
            id: subject,
            project: attributes_for(:project)

      assert_response response
      if assigns(:up).try(:resource).present?
        ch_method.call subject
                         .updated_at
                         .iso8601(6),
                       assigns(:up)
                         .try(:resource)
                         .try(:updated_at)
                         .try(:iso8601, 6)
      else
        assert false, "can't be changed" if changed
      end
    end

    def general_destroy(response = 302, differences = [['Announcement.count', 0]])
      subject # Trigger
      assert_differences(differences) do
        delete :destroy,
               id: subject
      end

      assert_response response
    end

    ####################################
    # As Guest
    ####################################
    test 'guest should not post create' do
      general_create
    end

    test 'guest should not delete destroy' do
      general_destroy
    end

    ####################################
    # As User
    ####################################
    test 'user should not post create' do
      sign_in create(:user)

      general_create
    end

    test 'user should not delete destroy' do
      sign_in create(:user)

      general_destroy
    end

    ####################################
    # As Member
    ####################################
    test 'member should not post create' do
      sign_in create_member(holland)

      general_create
    end

    test 'member should not delete destroy' do
      sign_in create_member(holland)

      general_destroy
    end
    ####################################
    # As Manager
    ####################################
    test 'manager should post create' do
      sign_in create_manager(holland)

      general_create
    end

    test 'manager should not delete destroy' do
      sign_in create_manager(holland)

      general_destroy
    end
    ####################################
    # As Owner
    ####################################
    test 'owner should not post create' do
      sign_in create_owner(holland, holland_owner)

      general_create
    end

    test 'owner should not delete destroy' do
      sign_in create_owner(holland)

      general_destroy
    end
    ####################################
    # As Staff
    ####################################
    let(:staff) { FactoryGirl.create(:user, :staff) }

    test 'staff should post create' do
      sign_in staff

      general_create 302, [['Announcement.count', 1]]
    end

    test 'staff should delete destroy' do
      sign_in staff

      general_destroy 302, [['Announcement.count', -1]]
    end
  end
end
