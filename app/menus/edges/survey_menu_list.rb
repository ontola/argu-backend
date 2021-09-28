# frozen_string_literal: true

class SurveyMenuList < ApplicationMenuList
  include Helpers::FollowMenuItems
  include Helpers::ShareMenuItems
  include Helpers::ActionMenuItems
  include SettingsHelper

  has_action_menu
  has_follow_menu
  has_share_menu
  has_menu :settings,
           iri_base: -> { resource.root_relative_iri },
           menus: -> { settings_menu_items }

  private

  def settings_menu_items # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    submission = resource.submission_for(user_context)
    submission_item =
      if submission
        setting_item(:submission, href: submission.iri)
      else
        setting_item(:participate, href: resource.submission_collection.action(:create).iri)
      end

    [
      submission_item,
      setting_item(
        :coupon_batches,
        image: 'fa-link',
        label: I18n.t('argu.CouponBatch.label'),
        href: collection_iri(resource, :coupon_batches)
      ),
      setting_item(
        :submissions,
        label: I18n.t('argu.Submission.plural_label'),
        href: collection_iri(resource, :submissions, display: :table)
      ),
      setting_item(:form, href: resource.action_body, image: 'fa-edit'),
      setting_item(:typeform, href: resource.manage_iri, image: 'fa-external-link')
    ]
  end

  def action_menu_items
    [
      edit_link,
      external_link,
      move_link,
      new_update_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end

  def external_link
    return unless resource.manage_iri

    menu_item(
      :external,
      image: 'fa-external-link',
      label: I18n.t('menus.default.typeform'),
      href: resource.manage_iri,
      policy: :update?
    )
  end
end
