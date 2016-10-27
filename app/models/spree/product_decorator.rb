Spree::Product.class_eval do
  #TODO: case delete product should delete sale product
  has_many :sale_products, dependent: :destroy
  has_many :active_sale_events, through: :sale_products
#TODO: allow nil on delegate
  delegate :available, :live_active, :live_active_and_hidden, to: :active_sale_events, prefix: true, allow_nil: true

  delegate_belongs_to :master, :display_discount_price, :discount_price_if_sale_live, :have_discount?

  # Find live and active taxons for a product.
  def find_live_taxons
    Spree::Taxon.joins([:active_sale_events, :products]).where(spree_products: { id: id }).merge(Spree::ActiveSaleEvent.available)
  end

#TODO: refactor
  # if there is at least one active sale event which is live and active.
  def live?
    available? && (!active_sale_events_available.blank? || !find_live_taxons.blank?)
  end

end
