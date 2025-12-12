class Address < ApplicationRecord
  PROVINCE_CODES = {
    "ONTARIO" => "ON",
    "BRITISH COLUMBIA" => "BC",
    "ALBERTA" => "AB",
    "QUEBEC" => "QC",
    "MANITOBA" => "MB",
    "SASKATCHEWAN" => "SK",
    "NOVA SCOTIA" => "NS",
    "NEW BRUNSWICK" => "NB",
    "NEWFOUNDLAND AND LABRADOR" => "NL",
    "NORTHWEST TERRITORIES" => "NT",
    "PRINCE EDWARD ISLAND" => "PE",
    "NUNAVUT" => "NU",
    "YUKON" => "YU"
  }.freeze

  def province_code
    PROVINCE_CODES[province.strip.upcase] || province.strip.upcase
  end

  belongs_to :customer

  before_save :unset_other_primary, if: :is_primary?

  validates :street, :city, :postal_code, :province, presence: true
  validates :is_primary, inclusion: { in: [ true, false ] }

  def full_address
    [ street, city, province, postal_code ].compact.join(", ")
  end

  private

  def unset_other_primary
    customer.addresses.where.not(id: id).update_all(is_primary: false)
  end
end
