class ConverExternalIRIToIRI < ActiveRecord::Migration[6.1]
  def change
    Property.where(predicate: NS.argu[:externalIRI]).update_all('iri = string')
  end
end
