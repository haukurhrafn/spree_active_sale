require 'rails_helper'

describe Spree::Product do

  let(:product) { FactoryGirl.create(:product) }
  let(:active_sale_event) { FactoryGirl.create(:active_sale_event, discount: 10) }
  let(:taxon) { create(:taxon) }

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
    it { expect(subject.find_live_taxons).to include taxon }
  end

  describe '#live?' do
    it { expect(subject.send(:live?)).to eql false }
  end


end
