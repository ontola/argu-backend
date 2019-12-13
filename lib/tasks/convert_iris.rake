# frozen_string_literal: true

namespace :iris do
  desc "Convert iri's"
  task convert: :environment do
    argu_hostname = ApplicationRecord.connection.quote_string(Rails.application.config.host_name)
    convert_iris('argu.co/', "#{argu_hostname}/")
    custom_iri_prefixes.each do |iri_prefix|
      old_hostname = ApplicationRecord.connection.quote_string(iri_prefix)
      new_hostname = convert_hostname(old_hostname)
      convert_iris(old_hostname, new_hostname)
    end
  end

  def convert_hostname(old)
    return "staging.#{old}" if Rails.application.config.host_name.include?('staging.')

    tld = URI(old).hostname.split('.').last
    old.sub(".#{tld}", '.localdev')
  end

  def convert_iris(from, to)
    # rubocop:disable Rails/SkipsModelValidations
    Tenant.update_all("iri_prefix = replace(iri_prefix, '#{from}', '#{to}')")
    Apartment::Tenant.each do
      Page.update_iris(from, to)
    end
    # rubocop:enable Rails/SkipsModelValidations
  end

  def custom_iri_prefixes
    Tenant.where('iri_prefix NOT LIKE ?', "%#{URI(Rails.application.config.frontend_url).hostname}%").pluck(:iri_prefix)
  end
end
