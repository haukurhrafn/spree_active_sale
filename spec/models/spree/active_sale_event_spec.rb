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

end
