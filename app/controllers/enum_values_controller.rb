# frozen_string_literal: true

class EnumValuesController < LinkedRails::EnumValuesController
  skip_before_action :check_if_registered

  private

  def authorize_action; end
end
