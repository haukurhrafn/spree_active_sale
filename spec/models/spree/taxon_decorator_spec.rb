require 'rails_helper'

describe Spree::Taxon do

  let!(:spree_taxon) { Spree::Taxon.create name: 'taxon1' }
  let!(:active_sale) { Spree::ActiveSale.create name: 'sale1' }
  let!(:active_sale_event) { Spree::ActiveSaleEvent.create name: "sale day 1", start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, active_sale: active_sale, discount: 10 }
  let!(:spree_sale_taxons) { Spree::SaleTaxon.create taxon: spree_taxon, active_sale_event: active_sale_event }
  let!(:product) { create :product }
  let!(:spree_products_taxons) {  Spree::Classification.create product: product, taxon: spree_taxon }

  describe 'associations' do
    it { is_expected.to have_many(:sale_taxons).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:active_sale_events).through(:sale_taxons) }
  end

  describe '#live_active_sale_events' do
    it { expect(spree_taxon.live_active_sale_events).to include active_sale_event }
  end

  describe '#live?' do
    context 'when true' do
      it { expect(spree_taxon.live?).to eq true }
    end
    context 'when false' do
      before do
        active_sale_event.is_active = false
        active_sale_event.save
      end
      it { expect(spree_taxon.live?).to eq false }
    end
    it 'expect to receive' do
      expect(spree_taxon).to receive(:live_active_sale_events)
      spree_taxon.live?
    end
  end

end
