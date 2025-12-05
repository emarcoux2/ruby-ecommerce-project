module Taxable
  TAX_RATES = Rails.application.config_for(:tax_rates)

  def tax_rate_for(province_code)
    TAX_RATES[province_code.to_s.upcase] || 0
  end

  def tax_cents(amount_cents, province_code)
    tax_rate = TAX_RATES[province_code] || 0
    (amount_cents * tax_rate).round
  end
end
