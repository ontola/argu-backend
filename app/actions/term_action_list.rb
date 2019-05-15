# frozen_string_literal: true

class TermActionList < ApplicationActionList
  private

  def create_description
    I18n.t('legal.continue_html', link: "[#{I18n.t('legal.documents.policy')}](/policy)")
  end

  def create_on_collection?
    false
  end

  def create_policy; end

  def create_label
    I18n.t('legal.documents.policy')
  end
end
