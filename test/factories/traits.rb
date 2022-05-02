# frozen_string_literal: true

FactoryBot.define do
  trait :with_iri do
    after(:build) do |object|
      object.instance_variable_set(
        :@iri,
        LinkedRails.iri(path: object.class.iri_template.expand(id: SecureRandom.uuid))
      )
    end
  end

  trait :with_follower do
    after :create do |resource|
      create(:follow,
             follower: create(:user, :follows_reactions_directly),
             followable: resource)
    end
  end
end
