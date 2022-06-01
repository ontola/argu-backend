# frozen_string_literal: true

Rails.application.config.active_storage.service =
  if Rails.env.test?
    :test
  elsif ENV['DO_ACCESS_ID']
    :digitalocean
  else
    :local
  end

Rails.application.config.active_storage.variant_processor = :vips

module VariantApartmentFix
  extend ActiveSupport::Concern

  def url(expires_in: ActiveStorage.service_urls_expire_in, disposition: :inline)
    return super if service.name == :digitalocean

    ActiveStorage::Current.url_options = {host: LinkedRails.host}

    DynamicURIHelper.rewrite(super)
  end
end

module BlobApartmentFix
  extend ActiveSupport::Concern

  def key
    self[:key] ||= "#{Apartment::Tenant.current}/#{self.class.generate_unique_secure_token(length: 28)}"
  end

  def service_url_for_direct_upload(expires_in: ActiveStorage.service_urls_expire_in)
    return super if service.name == :digitalocean

    DynamicURIHelper.rewrite(super)
  end

  def url(expires_in: ActiveStorage.service_urls_expire_in, disposition: :inline, filename: nil, **options)
    return super if service.name == :digitalocean

    ActiveStorage::Current.url_options = {host: LinkedRails.host}

    DynamicURIHelper.rewrite(super)
  end

  class_methods do
    def create_before_direct_upload!(**args)
      Apartment::Tenant.switch(Apartment::Tenant.current) do
        super
      end
    end
  end
end

Rails.application.config.to_prepare do
  ActiveStorage::Variant.prepend(VariantApartmentFix)
  ActiveStorage::Blob.prepend(BlobApartmentFix)
  ActiveStorage::Blob.validates :byte_size, numericality: {less_than: Rails.application.config.max_file_size}

  ActiveRecord::Base.class_eval do
    def self.find_signed!(signed_id, purpose: nil)
      Apartment::Tenant.switch(Apartment::Tenant.current) do
        super
      end
    end
  end

  ActiveStorage::BaseController.class_eval do
    include LinkedRails::Helpers::OntolaActionsHelper

    def handle_and_report_error(error)
      raise(error) unless error.is_a?(ActiveRecord::RecordInvalid)

      add_exec_action_header(response.headers, ontola_snackbar_action(error.message))
      response.status = 422
    end
  end
end
