require 'rails_helper'

describe Spree::Variant do

  let!(:spree_taxon) { Spree::Taxon.create name: 'taxon1' }
  let!(:active_sale) { Spree::ActiveSale.create name: 'sale1' }
  let!(:active_sale_event) { Spree::ActiveSaleEvent.create name: "sale day 1", start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, active_sale: active_sale, discount: 10 }
  let!(:spree_sale_taxons) { Spree::SaleTaxon.create taxon: spree_taxon, active_sale_event: active_sale_event }
  let!(:product) { create :product }
  let(:variant) { create :variant }
  let!(:spree_products_taxons) {  Spree::Classification.create product: product, taxon: spree_taxon }

  before do
    variant.product = product
    variant.save
  end

  subject { create :variant }

  describe 'delegate' do
    it { is_expected.to delegate_method(:active_sale_events_live_active).to(:product).with_prefix }
  end

  describe 'delegate_belongs_to' do
    it 'default_price' do
      expect(subject.default_price).to receive(:discounted_price_including_vat_for)
      subject.discounted_price_including_vat_for
    end
  end

  describe 'live_active_sale_event' do
    it 'expects to receive' do
      expect(subject).to receive(:get_sale_event)
      subject.live_active_sale_event
    end
  end

  describe 'live?' do
    context 'when active_sale_event is live?' do
      it { expect(variant.live?).to be true  }
    end
    context 'when active_sale_event is not live?' do
      before do
        active_sale_event.is_active = false
        active_sale_event.save
      end
      it { expect(variant.live?).to be false  }
    end

  end

  # describe 'discount_price_if_sale_live' do
  #   it { expect(variant.discount_price_if_sale_live).to be 19.99 }
  # end

end
