module Spree
  class SaleProduct < Spree::Base

    acts_as_list

    belongs_to :active_sale_event, class_name: 'Spree::ActiveSaleEvent'
    belongs_to :product, class_name: 'Spree::Product'
#TODO: fix delegate
    delegate :name, to: :product, allow_nil: true, prefix: true
    delegate :sale_name, to: :active_sale_event, allow_nil: true

#TODO: remove id validations, allow nil for uniqueness
    validates :active_sale_event, :product, presence: true
    validates :active_sale_event_id, uniqueness: { scope: :product_id, allow_blank: true, message: Spree.t(:already_exists, scope: [:active_sale, :event, :sale_product]) }
#TODO: allow nil
    delegate :discount, to: :active_sale_event, allow_nil: true

#TODO: delegate product_name, product_name=
    # def product_name
    #   product.try(:name)
    # end
    #
    # def product_name=(name)
    #   self.product.name ||= name if name.present?
    # end

    def product
      Spree::Product.unscoped { super }
    end

    def discount_price(amount = product.price)
      amount - ((amount * discount.to_f) / 100)
    end
  end
end
