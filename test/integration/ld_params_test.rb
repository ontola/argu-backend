# frozen_string_literal: true

require 'test_helper'

class LDParamsTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:motion) { create(:motion, parent: freetown, creator: administrator.profile) }
  let(:administrator) { create_administrator(freetown) }

  test 'post create draft motion' do
    create_with_ld_params(
      collection_iri(freetown, :motions),
      Motion,
      {'Motion.count' => 1, 'Publication.where("published_at IS NOT NULL").count' => 0},
      'draft_motion.n3'
    )
  end

  test 'post create motion with expiry' do
    create_with_ld_params(
      collection_iri(freetown, :motions),
      Motion,
      {'Motion.where(expires_at: DateTime.parse("2050-01-01T23:01:00.000Z")).count' => 1},
      'motion_with_expiry.n3'
    )
  end

  test 'post create motion with cover photo as nquads' do
    create_with_ld_params(
      collection_iri(freetown, :motions),
      Motion,
      {'Motion.count' => 1, 'Publication.where("published_at IS NOT NULL").count' => 1, 'MediaObject.count' => 1},
      'motion_with_cover.n3',
      "<#{NS.ll['blobs/randomString']}>" => fixture_file_upload('cover_photo.jpg', 'image/jpg')
    )
    assert File.exist?(Motion.last.default_cover_photo.content.cover.file.path)
  end

  test 'post create motion with attachments as nquads' do
    create_with_ld_params(
      collection_iri(freetown, :motions),
      Motion,
      {'Motion.count' => 1, 'MediaObject.count' => 2},
      'motion_with_attachments.n3',
      "<#{NS.ll['blobs/randomString1']}>" => fixture_file_upload('cover_photo.jpg', 'image/jpg'),
      "<#{NS.ll['blobs/randomString2']}>" => fixture_file_upload('profile_photo.png', 'image/png')
    )
  end

  test 'post create motion with arguments as nquads' do
    Sidekiq::Testing.inline! do
      create_with_ld_params(
        collection_iri(freetown, :motions),
        Motion,
        {'Motion.count' => 1, 'Argument.count' => 3, 'Motion.published.count' => 1, 'Argument.published.count' => 3},
        'motion_with_arguments.n3'
      )
    end
  end

  private

  def create_with_ld_params(path, klass, differences, fixture, **params)
    sign_in administrator
    assert_difference(differences) do
      post path,
           params: {
             "<#{NS.ll[:graph]}>" => fixture_file_upload(fixture, 'text/n3')
           }.merge(params),
           headers: argu_headers(accept: :nq)
    end
    assert_response 201
    assert_equal response.headers['Location'], klass.last.iri
  end
end
