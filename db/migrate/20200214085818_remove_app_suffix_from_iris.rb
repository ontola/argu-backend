class RemoveAppSuffixFromIris < ActiveRecord::Migration[5.2]
  def change
    convert_iris('app.argu.co/', 'argu.co/')
    convert_iris('app.staging.argu.co/', 'staging.argu.co/')
  end

  private

  def convert_iris(from, to)
    Tenant.update_all("iri_prefix = replace(iri_prefix, '#{from}', '#{to}')")
    Apartment::Tenant.each do
      Page.update_iris(from, to)
    end
  end
end
