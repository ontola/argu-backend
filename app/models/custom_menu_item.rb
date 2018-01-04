# frozen_string_literal: true

class CustomMenuItem < ApplicationRecord
  def label
    label_translation ? I18n.t(super) : super
  end
end
