# frozen_string_literal: true
module Argu
  module TestHelpers
    module AutomatedTests
      module Asserts
        def assert_has_content
          "assert_select '##{name.split('sTest')[0].underscore}_content', 'C'"
        end

        def assert_has_drafts
          'send(user_type).reload.has_drafts?'
        end

        def assert_has_title
          "assert_select '##{name.split('sTest')[0].underscore}_title', '#{name.split('sTest')[0]}'"
        end

        def assert_has_media_object
          'assert_equal 1, resource.media_objects.count'
        end

        def assert_is_published
          'resource.is_published?'
        end

        def assert_not_a_user
          'assigns(:_not_a_user_caught)'
        end

        def assert_not_authorized
          'assigns(:_not_authorized_caught)'
        end

        def assert_no_drafts
          '!send(user_type).reload.has_drafts?'
        end

        def assert_not_published
          '!resource.is_published?'
        end

        def assert_photo_identifier
          'assert_equal "cover_photo.jpg", resource.default_cover_photo.content_identifier'
        end

        def assert_attachment_identifier
          'assert_equal "cover_photo.jpg", resource.attachments.first.content_identifier'
        end

        def exp_res(should: false, response: 403, asserts: [], analytics: nil)
          {should: should, response: response, asserts: asserts, analytics: analytics}
        end
      end
    end
  end
end
