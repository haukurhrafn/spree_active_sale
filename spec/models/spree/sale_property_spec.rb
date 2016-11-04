require 'rails_helper'

describe Spree::SaleProperty do

  describe 'validations' do
    it { is_expected.to validate_presence_of(:active_sale_event) }
    it { is_expected.to validate_presence_of(:property) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:active_sale_event) }
    it { is_expected.to belong_to(:property) }
  end

  describe 'delegate' do
    it { is_expected.to delegate_method(:name).to(:property) }
  end

  describe '#property_name=' do
    context 'name is blank' do
      before do
        subject.property_name = nil
      end
      it { expect(subject.property).to eq nil }
    end
    context 'name is not blank' do
      before do
        subject.property_name = "property_name"
      end
      it { expect(subject.property).to eq (Spree::Property.find_by_name("property_name")) }
    end
  end

end
