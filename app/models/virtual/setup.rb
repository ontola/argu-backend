# frozen_string_literal: true

class Setup < VirtualResource
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Updatable
  attr_accessor :user

  delegate :url, :first_name, :last_name, :errors, to: :user
  validates :first_name, :last_name, presence: true, if: -> { ActsAsTenant.current_tenant.requires_intro? }
  validates :url,
            allow_nil: true,
            length: 3..50,
            format: {
              with: Shortname
                      .validators
                      .detect { |validator| validator.is_a?(ActiveModel::Validations::FormatValidator) }
                      .options[:with],
              message: I18n.t('profiles.should_start_with_capital')
            }
  def id; end

  def iri_opts
    {fragment: :resource}
  end
end
