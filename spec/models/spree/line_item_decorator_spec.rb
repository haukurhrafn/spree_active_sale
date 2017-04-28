require 'rails_helper'

describe Spree::Product do

  let(:tax_zone) { nil }
  let!(:spree_taxon) { Spree::Taxon.create name: 'taxon1' }
  let!(:active_sale) { Spree::ActiveSale.create name: 'sale1' }
  let!(:active_sale_event) { Spree::ActiveSaleEvent.create name: "sale day 1", start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, active_sale: active_sale, discount: 10 }
  let!(:spree_sale_taxons) { Spree::SaleTaxon.create taxon: spree_taxon, active_sale_event: active_sale_event }
  let!(:shipping_category) { Spree::ShippingCategory.new }
  let!(:tax_category) { Spree::TaxCategory.new }
  let!(:option_values) { [Spree::OptionValue.new] }
  let!(:product) { Spree::Product.create(name: 'product1', available_on: 1.day.ago, price: 100, cost_price: 90, shipping_category: shipping_category, tax_category: tax_category) }
  # let!(:product) { create :product }
  # let!(:variant) { create :variant, product: product }
  let!(:variant) { Spree::Variant.create(price: 100, cost_price: 90, is_master: false, track_inventory: false, product: product, option_values: option_values, product: product) }
  let!(:price) { Spree::Price.new(variant: variant, amount: 100, currency: 'USD') }
  let!(:spree_products_taxons) {  Spree::Classification.create product: product, taxon: spree_taxon }
  let!(:user) { create :user }
  let!(:order) { Spree::Order.create(user: user) }
  let!(:line_item) { Spree::LineItem.create(variant: variant, order: order, quantity: 1, price: 100, currency: 'USD', cost_price: '100') }
  let!(:sale_product) { Spree::SaleProduct.create(product: product, active_sale_event: active_sale_event) }
  subject { line_item }

  describe 'delegate' do
    it { is_expected.to delegate_method(:live?).to(:product) }
  end

  describe '#update_price' do
    it 'receive' do
      expect(subject).to receive(:variant).twice
      expect(subject.variant).to receive(:discounted_price_including_vat_for).with({ tax_zone: tax_zone })
      subject.update_price
    end
  end

end
