require 'rails_helper'

describe Spree::ActiveSale do

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:permalink) }
    it { is_expected.to validate_uniqueness_of(:permalink).allow_blank }
  end

  describe 'associations' do
    it { is_expected.to have_many(:active_sale_events).class_name('Spree::ActiveSaleEvent').conditions(deleted_at: nil).dependent(:destroy) }
  end

  describe 'delete' do
    let(:active_sale) { create(:active_sale) }

    before do
      active_sale.active_sale_events.create
      active_sale.delete
    end

    it { expect(active_sale.deleted_at).not_to be nil }
  end

  describe 'to_param' do
    let(:active_sale) { create(:active_sale) }

    it { expect(active_sale.to_param).to eq(active_sale.permalink) }

  end

  describe 'self.config' do
    it { expect { |block| Spree::ActiveSale.config(&block) }.to yield_with_args(Spree::ActiveSaleConfig) }
  end

end
