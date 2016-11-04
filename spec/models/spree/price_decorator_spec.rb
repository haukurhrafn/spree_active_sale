require 'rails_helper'

describe Spree::Price do

  describe 'delegations' do
    it { is_expected.to delegate_method(:discount_price_if_sale_live).to(:variant) }
    it { is_expected.to delegate_method(:tax_category).to(:variant) }
  end

  describe '#discounted_price_including_vat_for' do
    let(:zone) { Spree::Zone.new }
    let(:price_options) { { tax_zone: zone } }

    context 'when called with a non-default zone' do
      it "returns the correct price including another VAT to two digits" do
        expect(subject).to receive(:gross_amount)
        expect(subject).to receive(:discount_price_if_sale_live)
        subject.discounted_price_including_vat_for({ tax_zone: zone })
      end
    end
  end
end
