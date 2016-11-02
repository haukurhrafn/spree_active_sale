require 'spec_helper'

describe Spree::ActiveSalesController, type: :controller do
  let(:user) { mock_model Spree::User, :last_incomplete_spree_order => nil, :spree_api_key => 'fake' }
  let(:sale) { mock_model Spree::ActiveSale, parmalink: 'sale1' }
  let(:sale_event) { mock_model Spree::ActiveSaleEvent }
  let(:searcher) { double Spree::Core::Search::Base }
  let(:sale_events) { [sale_event] }
  let(:taxonomy) { mock_model Spree::Taxonomy }
  let(:taxonomies) { [taxonomy] }
  let(:sale_property) { mock_model Spree::SaleProperty }
  let(:sale_properties) { [sale_property] }
  let(:product) { mock_model Spree::Product }
  let(:products) { [product] }

  before do
    allow(controller).to receive(:spree_current_user).and_return(user)
    allow(Spree::Config).to receive_message_chain(:searcher_class, :new).and_return(searcher)
    allow(searcher).to receive(:current_user=).and_return(user)
    allow(searcher).to receive(:current_currency=).and_return("USD")
    allow(searcher).to receive(:retrieve_sales).and_return(sale_events)
    allow(Spree::Taxonomy).to receive(:includes).and_return(taxonomies)
  end

  describe '#index' do
    def send_request
      spree_get :index
    end

    describe 'expect to receive' do
      it { expect(controller).to receive(:spree_current_user).and_return(user) }
      it { expect(Spree::Config).to receive_message_chain(:searcher_class, :new).and_return(searcher) }
      after { send_request }
    end

    it "expects to assignes" do
      send_request
      expect(assigns(:sale_events)).to eq(sale_events)
    end

    it 'expects to redirect to root' do
      send_request
      expect(response).to  render_template :index
    end
  end

  describe '#show' do

    let(:active_sale) { sale }

    before do
      allow(Spree::ActiveSale).to receive(:find_by_permalink!).and_return(active_sale)
      allow(active_sale).to receive_message_chain(:active_sale_events, :live_active_and_hidden, :first).and_return(sale_event)
      allow(sale_event).to receive_message_chain(:sale_properties, :includes).and_return(sale_properties)
      allow(sale_event).to receive_message_chain(:products, :active).and_return(products)
    end

    def send_request
      spree_get :show, id: sale.parmalink
    end

    context 'single product sale' do

      before do
        allow(sale_event).to receive(:single_product_sale?).and_return true
      end

      describe 'expect to receive' do
        it { expect(controller).to receive(:spree_current_user).and_return(user) }
        after { send_request }
      end

      it "expects to assignes" do
        send_request
        expect(assigns(:sale_event)).to eq(sale_event)
        expect(assigns(:taxonomies)).to eq(taxonomies)
      end

      it 'expects to redirect to root' do
        send_request
        expect(response).to  redirect_to product
      end

    end

    context 'not a single product sale' do

      before do
        allow(sale_event).to receive(:single_product_sale?).and_return false
      end

      describe 'expect to receive' do
        it { expect(controller).to receive(:spree_current_user).and_return(user) }
        after { send_request }
      end

      it "expects to assignes" do
        send_request
        expect(assigns(:sale_event)).to eq(sale_event)
        expect(assigns(:taxonomies)).to eq(taxonomies)
      end

      it 'expects to redirect to root' do
        send_request
        expect(response).to render_template :show
        expect(controller.send(:accurate_title)).to eq(sale_event.name)
      end

    end

    context 'sale event not present' do

      before do
        allow(active_sale).to receive_message_chain(:active_sale_events, :live_active_and_hidden, :first).and_return(nil)
        allow(sale_event).to receive(:single_product_sale?).and_return false
      end

      describe 'expect to receive' do
        it { expect(controller).to receive(:spree_current_user).and_return(user) }
        after { send_request }
      end

      it "expects to assignes" do
        send_request
      end

      it 'expects to redirect to root' do
        send_request
        expect(response).to redirect_to root_url
      end

    end
  end

end
