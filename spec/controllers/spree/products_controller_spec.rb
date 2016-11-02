# coding: UTF-8
require 'spec_helper'

describe Spree::ProductsController, type: :controller do

  stub_authorization!

  let(:product) { mock_model(Spree::Product) }
  let(:products) { [product] }
  let(:taxon) { mock_model(Spree::Taxon) }
  let(:user) { mock_model(Spree.user_class, :has_spree_role? => true, :last_incomplete_spree_order => nil, :spree_api_key => 'fake') }
  let(:variants) { [variants] }

  describe '#show' do

    before do
      allow(Spree::Product).to receive(:with_deleted).and_return(products)
      allow(controller).to receive(:spree_current_user).and_return(user)
      allow(products).to receive_message_chain(:includes, :friendly, :find).and_return(product)
      allow(product).to receive_message_chain(:taxons, :first).and_return(taxon)
    end

    context 'when product is live' do

      before do
        allow(product).to receive(:live?).and_return(true)
      end

      def send_request
        spree_get :show, { id: product.to_param }
      end

      describe 'expect to receive' do
        it { expect(controller).to receive(:spree_current_user).and_return(user) }
        after { send_request }
      end

      it 'expects to assign' do
        send_request
      end

      it 'expects to render template show' do
        send_request
        expect(response).to render_template :show
      end
    end

    context 'when product is not live' do

      before do
        allow(product).to receive(:live?).and_return(false)
      end

      def send_request
        spree_get :show, { id: product.to_param }
      end

      describe 'expect to receive' do
        it { expect(controller).to receive(:spree_current_user).and_return(user) }
        after { send_request }
      end

      it 'expects to assign' do
        send_request
        expect(:product).to eq(product)
        expect(:variants).to eq(variants)
        expect(:taxon).to eq(taxon)
      end

      it 'expects to redirect to root' do
        send_request
        expect(response).to  redirect_to root_path
      end
    end
  end
end
