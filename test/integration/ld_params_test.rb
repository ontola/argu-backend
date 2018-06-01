# frozen_string_literal: true

require 'test_helper'

class LDParamsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  let(:administrator) { create_administrator(freetown) }

  test 'post create blog_post with nested fields as nquads' do
    motion
    create_with_ld_params(
      collection_iri_path(motion, :blog_posts),
      BlogPost,
      [['BlogPost.count', 1], ['Activity.count', 2]],
      'blog_post.n3'
    )
  end

  test 'post create motion with cover photo as nquads' do
    create_with_ld_params(
      collection_iri_path(freetown, :motions),
      Motion,
      [['Motion.count', 1], ['MediaObject.count', 1]],
      'motion_with_cover.n3',
      "<#{NS::LL['blobs/randomString']}>" => fixture_file_upload('cover_photo.jpg', 'image/jpg')
    )
  end

  test 'post create motion with attachments as nquads' do
    create_with_ld_params(
      collection_iri_path(freetown, :motions),
      Motion,
      [['Motion.count', 1], ['MediaObject.count', 2]],
      'motion_with_attachments.n3',
      "<#{NS::LL['blobs/randomString1']}>" => fixture_file_upload('cover_photo.jpg', 'image/jpg'),
      "<#{NS::LL['blobs/randomString2']}>" => fixture_file_upload('profile_photo.png', 'image/png')
    )
  end

  test 'post create motion with arguments as nquads' do
    create_with_ld_params(
      collection_iri_path(freetown, :motions),
      Motion,
      [['Motion.count', 1], ['Argument.count', 3]],
      'motion_with_arguments.n3'
    )
  end

  private

  def create_with_ld_params(path, klass, differences, fixture, params = {})
    sign_in administrator
    assert_differences(differences) do
      post path,
           params: {
             "<#{NS::LL[:graph]}>" => fixture_file_upload(fixture, 'text/n3')
           }.merge(params),
           headers: argu_headers(accept: :nq)
    end
    assert_response 201
    assert_equal response.headers['Location'], klass.last.iri
  end
end
