# frozen_string_literal: true

require 'test_helper'

module Portal
  class AnnouncementsControllerTest < ActionController::TestCase
    subject do
      create(:announcement,
             :everyone)
    end
    define_freetown

    ####################################
    # Shared
    ####################################

    def general_new(response = 302)
      get :new,
          params: {forum_id: freetown}

      assert_response response
    end

    def general_create(response = 302, differences = {'Announcement.count' => 0})
      assert_difference(differences) do
        post :create,
             params: {announcement: attributes_for(:announcement)}
      end

      assert_response response
    end

    def general_edit(response = 302)
      get :edit,
          params: {id: subject}

      assert_response response
    end

    def general_update(response = 302, changed = false)
      ch_method = method(changed ? :assert_not_equal : :assert_equal)

      patch :update,
            params: {
              id: subject
            }

      assert_response response
      if assigns(:up).try(:resource).present?
        ch_method.call subject
                         .updated_at
                         .iso8601(6),
                       assigns(:up)
                         .try(:resource)
                         .try(:updated_at)
                         .try(:iso8601, 6)
      elsif changed
        assert false, "can't be changed"
      end
    end

    def general_destroy(response = 302, differences = {'Announcement.count' => 0})
      subject # Trigger
      assert_difference(differences) do
        delete :destroy,
               params: {id: subject}
      end

      assert_response response
    end

    ####################################
    # As Guest
    ####################################
    test 'guest should not post create' do
      general_create 302
    end

    test 'guest should not delete destroy' do
      general_destroy 302
    end

    ####################################
    # As User
    ####################################
    test 'user should not post create' do
      sign_in create(:user)

      general_create 403
    end

    test 'user should not delete destroy' do
      sign_in create(:user)

      general_destroy 403
    end

    ####################################
    # As Initiator
    ####################################
    test 'member should not post create' do
      sign_in create_initiator(freetown)

      general_create 403
    end

    test 'member should not delete destroy' do
      sign_in create_initiator(freetown)

      general_destroy 403
    end
    ####################################
    # As Moderator
    ####################################
    test 'moderator should post create' do
      sign_in create_moderator(freetown)

      general_create 403
    end

    test 'moderator should not delete destroy' do
      sign_in create_moderator(freetown)

      general_destroy 403
    end
    ####################################
    # As Administrator
    ####################################
    test 'administrator should not post create' do
      sign_in create_administrator(freetown)

      general_create 403
    end

    test 'administrator should not delete destroy' do
      sign_in create_administrator(freetown)

      general_destroy 403
    end
    ####################################
    # As Staff
    ####################################
    let(:staff) { FactoryBot.create(:user, :staff) }

    test 'staff should post create' do
      sign_in staff

      general_create 302, 'Announcement.count' => 1
    end

    test 'staff should delete destroy' do
      sign_in staff

      general_destroy 303, 'Announcement.count' => -1
    end
  end
end
