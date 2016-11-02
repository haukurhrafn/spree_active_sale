require 'spec_helper'

describe Spree::OrdersController, type: :controller do

  stub_authorization!

  describe '#show' do
    let(:user) { create(:user) }
    let(:order) { create(:order_with_totals) }

    before do
      allow(controller).to receive(:spree_current_user).and_return(user)
    end

    def send_request(params = {})
      get :show, params.merge(id: order.number)
    end

    describe 'expect to receive' do
      it { expect(controller).to receive(:spree_current_user).and_return(user) }
      after { send_request }
    end

    it 'expects to assign return_authorizations' do
      send_request
    end

    it 'expects to render template index' do
      send_request
      expect(response).to render_template :show
    end
  end
end
