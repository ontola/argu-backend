# frozen_string_literal: true

class SurveyMenuList < ApplicationMenuList
  include SettingsHelper

  has_action_menu
  has_follow_menu
  has_share_menu
  has_tabs_menu

  private

  def form_item
    return if resource.action_body.blank?

    setting_item(
      :form,
      label: I18n.t('menus.surveys.fields'),
      href: resource.action_body.collection_iri(:custom_form_fields),
      image: 'fa-edit'
    )
  end

  def submission_item
    submission = resource.submission_for(user_context)

    if submission
      setting_item(:submission, href: submission.iri)
    else
      setting_item(:participate, href: resource.submission_collection.action(:create).iri)
    end
  end

  def tabs_menu_items # rubocop:disable Metrics/MethodLength
    [
      submission_item,
      setting_item(
        :coupon_batches,
        image: 'fa-link',
        label: I18n.t('argu.CouponBatch.label'),
        href: resource.collection_iri(:coupon_batches)
      ),
      setting_item(
        :submissions,
        label: I18n.t('argu.Submission.plural_label'),
        href: resource.collection_iri(:submissions, display: :table)
      ),
      form_item,
      edit_link,
      external_link
    ]
  end

  def action_menu_items
    [
      move_link,
      new_update_link,
      copy_share_link(resource.iri),
      transfer_link,
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
