# frozen_string_literal: true

class Employment < Edge
  enhance ProfilePhotoable
  enhance LinkedRails::Enhancements::Createable
  enhance LinkedRails::Enhancements::Updateable

  property :organization_name, :string, NS::ARGU[:organizationName]
  property :job_title, :string, NS::SCHEMA[:roleName]
  property :industry, :integer, NS::SCHEMA[:industry], enum: {
    argiculutre: 1, food_industry: 2, textile: 3, wood_industry: 4, paper_and_cardboard: 5, grafimedia: 6, chemistry: 7,
    rubber_and_plastic: 8, production_of_other_mineral_products: 9, metal: 10, metal_production: 11,
    manufacture_of_metal_products: 12, manufacture_of_electronics: 13, manufacture_of_electrical_appliances: 14,
    manufacture_of_other_machines_and_equipment: 15, car_industry: 16, manufacture_of_other_means_of_transport: 17,
    furniture_industry: 18, social_work_facilities: 19, repair_and_installation_of_machines: 20, energy_companies: 21,
    waste_treatment_and_recycling: 22, remediation_and_other_waste_management: 23,
    residential_building_and_construction_for_public_life: 24, ground_water_and_road_construction: 25,
    construction_industry: 26, car_trade_and_repair: 27, wholesale: 28, retail: 29, freight_transport: 30,
    inland_shipping: 31, transport_and_logistics: 32, catering_industry: 33, accommodation: 34,
    food_and_beverage_outlets: 35, rental_of_and_trade_in_real_estate: 36, architects_and_engineers: 37,
    rental_of_movable_property: 38, catering_cleaning_companies_and_gardeners: 39, other_business_services: 40,
    public_administration_and_government_services: 41, education: 42, healthcare: 43, nursing: 44, social_services: 45,
    sport_and_recreation: 46
  }

  parentable :page
  validates :organization_name, presence: true, length: {maximum: 110}
  validates :job_title, presence: true, length: {maximum: 110}
  validates :industry, presence: true

  alias_attribute :display_name, :organization_name

  def parent_collections(user_context = nil)
    [Employment.root_collection(user_context: user_context)]
  end

  class << self
    def iri_namespace
      NS::RIVM
    end

    def require_profile_photo?
      false
    end
  end
end
