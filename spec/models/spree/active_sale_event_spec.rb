require 'rails_helper'

describe Spree::ActiveSaleEvent, type: :model do

  let(:active_sale_event) { create(:active_sale_event) }
  let(:product) { create(:product) }
  let(:active_sale) { create(:active_sale) }
  describe 'associations' do
    it { is_expected.to have_many(:sale_images).order(:position).dependent(:destroy) }
    it { is_expected.to have_many(:sale_products).order(:position).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:sale_products) }
    it { is_expected.to have_many(:sale_taxons).order(:position).dependent(:destroy) }
    it { is_expected.to have_many(:taxons).order(:position).through(:sale_taxons) }
    it { is_expected.to have_many(:sale_properties).dependent(:destroy) }
    it { is_expected.to have_many(:properties).through(:sale_properties) }
    it { is_expected.to belong_to(:active_sale) }
  end


  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_presence_of(:active_sale) }
  end

  describe 'delete' do
    before { active_sale_event.delete }
    it { expect(active_sale_event.deleted_at).not_to eq nil }
  end

  describe 'permalink' do
    context 'product is present and single product sale' do
      before do
        subject.single_product_sale = true
        subject.products << product
      end
      it { expect(subject.permalink).to eq(product) }
    end
    context 'product is not present' do
      before do
        subject.active_sale = active_sale
      end
      it { expect(subject.permalink).to eq(subject.active_sale) }
    end
  end

  describe 'product' do
    before do
      active_sale_event.products << product
      active_sale_event.products.create
    end

    it { expect(active_sale_event.product).to eq(product) }
  end

  describe 'live?' do
    context 'when start_and_dates_available' do
      before do
        subject.start_date = 2.day.ago
        subject.end_date = 1.day.from_now
      end
      it { expect(subject.live?(1.day.ago)).to eq true }

      context 'when permanent' do
        before do
          subject.is_permanent = true
        end
        it { expect(subject.live?).to eq true }
      end

      context 'event is not live' do
        before do
          subject.start_date = 2.day.ago
          subject.end_date = 1.day.ago
        end
        it { expect(subject.live?).to eq false }
      end
    end
    context 'when start_and_dates not available' do
      it { expect(subject.live?).to eq nil }
    end
  end

  describe 'upcoming?' do
    context 'when start_and_dates_available' do
      before do
        subject.start_date = 1.day.from_now
        subject.end_date = 3.day.from_now
      end
      it { expect(subject.upcoming?).to eq true }

      context 'event is not upcoming' do
        before do
          subject.start_date = 2.day.ago
          subject.end_date = 1.day.ago
        end
        it { expect(subject.upcoming?).to eq false }
      end
    end
    context 'when start_and_dates not available' do
      it { expect(subject.upcoming?).to eq nil }
    end
  end

  describe 'past?' do
    context 'when start_and_dates_available' do
      before do
        subject.start_date = 3.day.ago
        subject.end_date = 1.day.ago
      end
      it { expect(subject.past?).to eq true }

      context 'event is not in past' do
        before do
          subject.start_date = 2.day.from_now
          subject.end_date = 4.day.from_now
        end
        it { expect(subject.past?).to eq false }
      end
    end
    context 'when start_and_dates not available' do
      it { expect(subject.past?).to eq nil }
    end
  end

  describe 'live_and_active?' do
    context 'when only live' do
      before do
        subject.start_date = 2.day.ago
        subject.end_date = 1.day.from_now
        subject.is_active = false
      end
      it { expect(subject.live_and_active?(Time.current)).to eq false }
    end
    context 'when only active' do
      before do
        subject.start_date = 2.day.ago
        subject.end_date = 1.day.ago
        subject.is_active = true
      end
      it { expect(subject.live_and_active?(Time.current)).to eq false }
    end
    context 'when live and active' do
      before do
        subject.start_date = 2.day.ago
        subject.end_date = 1.day.from_now
        subject.is_active = true
      end
      it { expect(subject.live_and_active?(Time.current)).to eq true }
    end
  end

  describe 'time_left' do
    before do
      subject.end_date = 5.day.from_now
    end
    it { expect(subject.time_left.ceil.to_i).to eq(5.days.to_i) }
  end

  describe 'validate_start_and_end_date' do
    active_sale_event = Spree::ActiveSaleEvent.new
    active_sale_event.valid?
    it { expect(active_sale_event.valid?).to be false }
    it { expect(active_sale_event.errors).not_to be nil }
    active_sale_event.send(:validate_start_and_end_date)
  end

  describe 'validate_with_live_event' do
    let!(:spree_taxon) { Spree::Taxon.create name: 'taxon1' }
    let!(:active_sale) { Spree::ActiveSale.create name: 'sale1' }
    let!(:active_sale_event) { Spree::ActiveSaleEvent.create name: "sale day 1", start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, active_sale: active_sale, discount: 10 }
    let!(:spree_sale_taxons) { Spree::SaleTaxon.create taxon: spree_taxon, active_sale_event: active_sale_event }
    let!(:product) { create :product }
    let!(:spree_products_taxons) {  Spree::Classification.create product: product, taxon: spree_taxon }

    context 'when not a new record' do
      let!(:active_sale_event_1) { Spree::ActiveSaleEvent.new name: "sale day 2", start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, active_sale: active_sale, discount: 10 }
      it { expect(active_sale_event_1.valid?).to be false }
      it { expect(active_sale_event_1.errors).not_to be nil }
    end

    context 'when new record' do
      let!(:active_sale_event_2) { Spree::ActiveSaleEvent.new name: "sale day 1", start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, active_sale: active_sale, discount: 10 }
      it { expect(active_sale_event_2.valid?).to be false }
      it { expect(active_sale_event_2.errors).not_to be nil }
    end

  end

end
