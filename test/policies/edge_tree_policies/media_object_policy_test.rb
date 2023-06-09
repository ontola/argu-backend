# frozen_string_literal: true

require 'test_helper'
class MediaObjectPolicyTest < Argu::TestHelpers::PolicyTest
  define_cairo
  let(:cover_photo) { create(:image_object, about: motion, used_as: :cover_photo) }
  let(:attachment) { create(:media_object, about: motion, used_as: :attachment) }
  let(:profile_photo) { create(:image_object, about: create(:user), used_as: :profile_photo) }
  let(:cairo_profile_photo) { create(:image_object, about: cairo, used_as: :profile_photo) }
  let(:hidden_profile_photo) do
    create(:image_object, about: create(:user, is_public: false), used_as: :profile_photo)
  end

  test 'show cover_photo' do
    test_policy(cover_photo, :show, show_results)
  end

  test 'show attachment' do
    test_policy(attachment, :show, show_results)
  end

  test 'show profile_photo' do
    test_policy(profile_photo, :show, everybody_results)
  end

  test 'show profile_photo of hidden profile' do
    test_policy(hidden_profile_photo, :show, everybody_results)
  end

  test 'show profile_photo of closed forum' do
    test_policy(cairo_profile_photo, :show, everybody_results)
  end
end
