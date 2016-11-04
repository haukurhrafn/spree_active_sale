require 'rails_helper'

describe Spree::Product do

  let!(:spree_taxon) { Spree::Taxon.create name: 'taxon1' }
  let!(:active_sale) { Spree::ActiveSale.create name: 'sale1' }
  let!(:active_sale_event) { Spree::ActiveSaleEvent.create name: "sale day 1", start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, active_sale: active_sale, discount: 10 }
  let!(:spree_sale_taxons) { Spree::SaleTaxon.create taxon: spree_taxon, active_sale_event: active_sale_event }
  let!(:product) { create :product }
  let!(:spree_products_taxons) {  Spree::Classification.create product: product, taxon: spree_taxon }

  describe 'associations' do
    it { is_expected.to have_many(:sale_products).dependent(:destroy) }
    it { is_expected.to have_many(:active_sale_events).through(:sale_products) }
  end

  describe 'delegate' do
    it { is_expected.to delegate_method(:available).to(:active_sale_events).with_prefix }
    it { is_expected.to delegate_method(:live_active).to(:active_sale_events).with_prefix }
    it { is_expected.to delegate_method(:live_active_and_hidden).to(:active_sale_events).with_prefix }
  end

  describe '#find_live_taxons' do

    it { expect(product.find_live_taxons).to include spree_taxon }
  end

  describe '#live?' do

    context 'when live? is true' do
      before { product.available_on = 1.day.from_now }
      it { expect(product.send(:live?)).to eql false }
    end
    context 'when live? is false' do
      it { expect(product.send(:live?)).to eql true }
    end
  end


end
