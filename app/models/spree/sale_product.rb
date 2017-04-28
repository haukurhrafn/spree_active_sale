module Spree
  class SaleProduct < Spree::Base

    acts_as_list

    belongs_to :active_sale_event, class_name: 'Spree::ActiveSaleEvent'
    belongs_to :product, class_name: 'Spree::Product'

    delegate :name, to: :product, allow_nil: true, prefix: true
    delegate :sale_name, :discount, to: :active_sale_event, allow_nil: true

    validates :active_sale_event, :product, presence: true
    validates :active_sale_event_id, uniqueness: { scope: :product_id, allow_blank: true, message: Spree.t(:already_exists, scope: [:active_sale, :event, :sale_product]) }

    def product
      Spree::Product.unscoped { super }
    end

    def discount_price(amount = product.price)
      amount - ((amount * discount.to_f) / 100)
    end
  end
end
