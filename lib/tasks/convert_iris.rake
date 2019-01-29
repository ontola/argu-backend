# frozen_string_literal: true

namespace :iris do
  desc "Convert iri's"
  task convert: :environment do
    argu_hostname = ApplicationRecord.connection.quote_string(Rails.application.config.host_name)
    convert_iris('argu.co/', "#{argu_hostname}/")
    demo_hostname = ApplicationRecord.connection.quote_string(ENV['DEMO_HOSTNAME'] || 'demogemeente.localdev')
    convert_iris('demogemeente.nl/', "#{demo_hostname}/")
  end

  def convert_iris(from, to)
    Property.where(predicate: NS::ARGU[:iriPrefix].to_s).update_all("string = replace(string, '#{from}', '#{to}')")
    Widget.update_all("resource_iri = replace(resource_iri::text, '#{from}', '#{to}')::text[]")
  end
end
