module Convertible
  extend ActiveSupport::Concern

  included do
  end

  # Converts an item to another item, the convertible method was used, those relations will be assigned the newly created model
  # TODO: check if the receiving model has the same associated_model names before sending them over (else, delete)
  def convert_to(klass)
    if self.class != klass
      ActiveRecord::Base.transaction do
        shared_attributes = klass.column_names.reject { |n| !attribute_names.include?(n) || n == 'id' }
        new_model = klass.new Hash[shared_attributes.map { |i| [i, self.attributes[i]] }]
        convertible_associations.each do |association|
          klass_association = self.class.reflect_on_association(association)
          # Just to be sure
          if klass_association.macro == :has_many
            remote_association_name = klass_association.options[:as]
            self.send(association).each do |associated_model|
              associated_model.send("#{remote_association_name}=", new_model)
              associated_model.save
            end
            self.send association, :clear
          end
        end
        new_model.save
        {old: self.destroy, new: new_model}
      end
    end
  end

  module ClassMethods
    # Takes the association names which can be converted along with the object itself.
    # Note: destruction of non-convertible associations should be taken care of by dependent: :destroy
    def convertible(*relation)
      cattr_accessor :convertible_associations do
        relation
      end
    end
  end
end
