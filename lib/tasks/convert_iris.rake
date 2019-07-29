# frozen_string_literal: true

namespace :iris do
  desc "Convert iri's"
  task convert: :environment do
    argu_hostname = ApplicationRecord.connection.quote_string(Rails.application.config.host_name)
    convert_iris('argu.co/', "#{argu_hostname}/")
    demo_hostname = ApplicationRecord.connection.quote_string(ENV['DEMO_HOSTNAME'] || 'demogemeente.localdev')
    convert_iris('demogemeente.nl', demo_hostname)
  end

  def convert_iris(from, to)
    # rubocop:disable Rails/SkipsModelValidations
    Tenant.update_all("iri_prefix = replace(iri_prefix, '#{from}', '#{to}')")
    Apartment::Tenant.each do
      Widget.update_all("resource_iri = replace(resource_iri::text, '#{from}', '#{to}')::text[]")
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end
