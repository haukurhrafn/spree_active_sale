require 'rails_helper'

describe Spree::SaleProduct do

  let(:product) { FactoryGirl.create(:product) }
  let(:active_sale_event) { FactoryGirl.create(:active_sale_event, discount: 10) }

  before do
    subject.product = product
    subject.active_sale_event = active_sale_event
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:active_sale_event) }
    it { is_expected.to validate_presence_of(:product) }
    it { is_expected.to validate_uniqueness_of(:active_sale_event_id).scoped_to(:product_id).allow_blank.with_message(Spree.t(:already_exists, scope: [:active_sale, :event, :sale_product])) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:active_sale_event).class_name('Spree::ActiveSaleEvent') }
    it { is_expected.to belong_to(:product).class_name('Spree::Product') }
  end

  describe 'delegate' do
    it { is_expected.to delegate_method(:name).to(:product).with_prefix }
    it { is_expected.to delegate_method(:sale_name).to(:active_sale_event) }
    it { is_expected.to delegate_method(:discount).to(:active_sale_event) }
  end

  describe '#discount_price' do
    it { expect(subject.send(:discount_price, 10)).to eql 9.0 }
  end

end
