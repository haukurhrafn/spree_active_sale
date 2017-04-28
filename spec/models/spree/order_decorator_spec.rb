require 'rails_helper'

describe Spree::Order do

  let!(:user) { FactoryGirl.create(:user) }
  let!(:order) { FactoryGirl.create(:order_with_line_items, user: user, completed_at: nil) }

  describe 'delete_inactive_items' do

    before do
      order.delete_inactive_items
    end

    it { expect(order.line_items.length).to eq 0 }
  end

end
