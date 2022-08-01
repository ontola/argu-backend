# frozen_string_literal: true

require 'test_helper'

class LDParamsTest < ActionDispatch::IntegrationTest
  include ::Empathy::EmpJson::Helpers::Primitives

  define_freetown
  let!(:motion) { create(:motion, parent: freetown, creator: administrator.profile) }
  let(:administrator) { create_administrator(freetown) }

  test 'post create motion with creator' do
    create_with_ld_params(
      freetown.collection_iri(:motions),
      Motion,
      {'Motion.count' => 1},
      '.' => {
        NS.schema.name => 'Wat een motie.',
        NS.schema.text => 'Zowaar een heus idee.',
        NS.schema.creator => argu
      }
    )
    assert_equal(argu.profile, Motion.last.creator) if should
  end

  test 'post create draft motion' do
    publication = RDF::Node.new
    create_with_ld_params(
      freetown.collection_iri(:motions),
      Motion,
      {'Motion.count' => 1, 'Publication.where("published_at IS NOT NULL").count' => 0},
      '.' => {
        NS.schema.name => 'Wat een motie.',
        NS.schema.text => 'Zowaar een heus idee.',
        NS.argu[:arguPublication] => publication
      },
      publication => {
        NS.argu[:draft] => true
      }
    )
  end

  test 'post create motion with expiry' do
    create_with_ld_params(
      freetown.collection_iri(:motions),
      Motion,
      {'Motion.where(expires_at: DateTime.parse("2050-01-01T23:01:00.000Z")).count' => 1},
      '.' => {
        NS.schema.name => 'Wat een motie.',
        NS.schema.text => 'Zowaar een heus idee.',
        NS.argu[:expiresAt] => '2050-01-01T23:01:00.000Z'
      }
    )
  end

  test 'post create motion with cover photo' do
    cover_photo = RDF::Node.new

    create_with_ld_params(
      freetown.collection_iri(:motions),
      Motion,
      {'Motion.count' => 1, 'Publication.where("published_at IS NOT NULL").count' => 1, 'MediaObject.count' => 1},
      '.': {
        NS.schema.name => 'Wat een motie.',
        NS.schema.text => 'Zowaar een heus idee.',
        NS.ontola[:coverPhoto] => cover_photo
      },
      cover_photo => {
        NS.schema.encodingFormat => 'image/png',
        NS.schema.contentUrl => blob_for('cover_photo.jpg').signed_id
      }
    )
    assert_equal 'cover_photo.jpg', Motion.last.default_cover_photo.content.filename.to_s
  end

  test 'post create motion with attachments' do
    attachment1 = RDF::Node.new
    attachment2 = RDF::Node.new
    local = resource_iri(MediaObjectSerializer.enum_options(:content_source)[:local], root: argu)

    create_with_ld_params(
      freetown.collection_iri(:motions),
      Motion,
      {'Motion.count' => 1, 'MediaObject.count' => 2},
      '.': {
        NS.schema.name => 'Wat een motie.',
        NS.schema.text => 'Zowaar een heus idee.',
        NS.argu[:attachments] => [
          attachment1,
          attachment2
        ]
      },
      attachment1 => {
        NS.argu[:contentSource] => local,
        NS.schema.encodingFormat => 'image/png',
        NS.dbo.filename => 'Profile photo',
        NS.schema.contentUrl => blob_for('profile_photo.png').signed_id
      },
      attachment2 => {
        NS.argu[:contentSource] => local,
        NS.schema.encodingFormat => 'image/png',
        NS.dbo.filename => 'Cover photo',
        NS.schema.contentUrl => blob_for('cover_photo.jpg').signed_id
      }
    )
  end

  test 'post create motion with arguments' do
    argument1 = RDF::Node.new
    argument2 = RDF::Node.new

    Sidekiq::Testing.inline! do
      create_with_ld_params(
        freetown.collection_iri(:motions),
        Motion,
        {'Motion.count' => 1, 'Argument.count' => 2, 'Motion.published.count' => 1, 'Argument.published.count' => 2},
        '.': {
          NS.schema.name => 'Wat een motie.',
          NS.schema.text => 'Zowaar een heus idee.',
          NS.argu[:proArguments] => [
            argument1,
            argument2
          ]
        },
        argument1 => {
          NS.schema.name => 'Argument 1',
          NS.schema.text => 'Argument body'
        },
        argument2 => {
          NS.schema.name => 'Argument 2'
        }
      )
    end
  end

  private

  def blob_for(name)
    ActiveStorage::Blob.create_after_unfurling!(
      io: File.open(File.expand_path("test/fixtures/#{name}")),
      filename: name,
      content_type: 'image/jpeg'
    )
  end

  def create_with_ld_params(path, klass, differences, **params)
    sign_in administrator
    assert_difference(differences) do
      post path,
           params: params.to_emp_json.to_json,
           headers: argu_headers(accept: :empjson, content_type: :empjson)
    end
    assert_response 201
    assert_equal response.headers['Location'], klass.last.iri
  end
end
