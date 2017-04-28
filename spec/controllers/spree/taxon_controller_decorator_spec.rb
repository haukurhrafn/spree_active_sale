require 'spec_helper'

describe Spree::TaxonsController, type: :controller do
  let(:user) { mock_model Spree::User, :last_incomplete_spree_order => nil, :spree_api_key => 'fake' }
  let(:searcher) { double Spree::Core::Search::Base }
  let(:taxon) { mock_model Spree::Taxon, permalink: 'taxon1' }
  let(:taxonomy) { mock_model Spree::Taxonomy }
  let(:taxonomies) { [taxonomy] }
  let(:product) { mock_model Spree::Product }
  let(:products) { [product] }

  before do
    allow(controller).to receive(:spree_current_user).and_return(user)
    allow(Spree::Config).to receive_message_chain(:searcher_class, :new).and_return(searcher)
    allow(Spree::Taxonomy).to receive(:includes).and_return(taxonomies)
    allow(Spree::Taxon).to receive_message_chain(:friendly, :find).and_return(taxon)
    allow(taxon).to receive(:live?).and_return(true)
  end

  describe '#show' do
    def send_request
      spree_get :show, id: taxon.permalink
    end

    context 'when taxon is live' do

      before do
        allow(taxon).to receive(:live?).and_return(true)
        allow(searcher).to receive(:send).and_return(products)
      end

      describe 'expect to receive' do
        it { expect(controller).to receive(:spree_current_user).and_return(user) }
        it { expect(Spree::Config).to receive_message_chain(:searcher_class, :new).and_return(searcher) }
        after { send_request }
      end

      it "expects to assignes" do
        send_request
        expect(assigns(:taxon)).to eq(taxon)
        expect(assigns(:objects)).to eq(products)
        expect(assigns(:taxonomies)).to eq(taxonomies)
        expect(assigns(:view_type)).to eq('products')
        expect(assigns(:retrieve_type)).to eq('retrieve_products')
      end

      it 'expects to redirect to root' do
        send_request
        expect(response).to  render_template :show
      end

      context 'when view type is sales' do
        def send_request
          spree_get :show, id: taxon.permalink, view_type: 'sales'
        end

        it "expects to assignes" do
          send_request
          expect(assigns(:view_type)).to eq('sale_events')
          expect(assigns(:retrieve_type)).to eq('retrieve_sales')
        end

      end

    end

    context 'when taxon is not live' do

      before do
        allow(taxon).to receive(:live?).and_return(false)
      end

      describe 'expect to receive' do
        it { expect(controller).to receive(:spree_current_user).and_return(user) }
        after { send_request }
      end

      it "expects to assignes" do
        send_request
        expect(assigns(:taxon)).to eq(taxon)
      end

      it 'expects to redirect to root' do
        send_request
        expect(response).to  redirect_to root_path
      end

    end

  end
end
