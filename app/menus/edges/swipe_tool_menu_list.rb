# frozen_string_literal: true

class SwipeToolMenuList < SurveyMenuList
  private

  def tabs_menu_items
    [
      submission_item,
      setting_item(
        :submissions,
        label: I18n.t('argu.Submission.plural_label'),
        href: resource.collection_iri(:submissions, display: :table)
      ),
      form_item
    ]
  end

  def action_menu_items
    [
      edit_link,
      move_link,
      new_update_link,
      copy_share_link(resource.iri),
      transfer_link,
      *trash_and_destroy_links
    ]
  end
end
