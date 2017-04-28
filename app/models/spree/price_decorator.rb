Spree::Price.class_eval do

  delegate :discount_price_if_sale_live, :tax_category, to: :variant, allow_nil: true

  def discounted_price_including_vat_for(options)
    options = options.merge(tax_category: tax_category)
    gross_amount(discount_price_if_sale_live, options)
  end
end
