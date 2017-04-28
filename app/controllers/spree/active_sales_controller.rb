module Spree
  class ActiveSalesController < Spree::StoreController
    before_action :load_sale, except: :index
    before_action :load_taxonomies, only: :show
    before_action :redirect_to_product, if: :single_product_sale?, only: :show

    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    helper 'spree/taxons'
    helper 'spree/products'

    respond_to :html

    def index
      @searcher = Config.searcher_class.new(params)
      @searcher.current_user = try_spree_current_user
      @searcher.current_currency = current_currency
      @sale_events = @searcher.retrieve_sales
      respond_with(@sale_events)
    end

    def show
      return unless @sale_event
      respond_with(@sale_event)
    end

    private

      def accurate_title
        @sale_event ? @sale_event.name : super
      end

      def load_sale
        @active_sale = ActiveSale.find_by_permalink!(params[:id])
        @sale_event = @active_sale.active_sale_events.live_active_and_hidden(hidden: false).first
        if @sale_event.present?
          @sale_properties, @products = @sale_event.sale_properties.includes(:property), @sale_event.products.active
        else
          redirect_to root_path
        end
      end

      def load_taxonomies
        @taxonomies = Spree::Taxonomy.includes(root: :children)
      end

      def single_product_sale?
        @sale_event.single_product_sale? if @sale_event
      end

      def redirect_to_product
        redirect_to @products.first
      end
  end
end
