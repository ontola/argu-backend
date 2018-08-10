# frozen_string_literal: true

module Settingable
  module Model
    extend ActiveSupport::Concern

    included do
      attr_accessor :active, :tab
    end
  end
end
