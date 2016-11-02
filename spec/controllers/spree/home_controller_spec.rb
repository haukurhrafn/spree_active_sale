require 'spec_helper'

describe Spree::HomeController, type: :controller do
  let(:user) { mock_model Spree::User, :last_incomplete_spree_order => nil, :spree_api_key => 'fake' }
  let(:sale) { mock_model Spree::ActiveSale }
  let(:sale_event) { mock_model Spree::ActiveSaleEvent }
  let(:searcher) { double Spree::Core::Search::Base }
  let(:sale_events) { [sale_event] }
  let(:taxonomy) { mock_model Spree::Taxonomy }
  let(:taxonomies) { [taxonomy] }

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
      expect(assigns(:taxonomies)).to eq(taxonomies)
    end

    it 'expects to redirect to root' do
      send_request
      expect(response).to  render_template :index
    end
  end
end
