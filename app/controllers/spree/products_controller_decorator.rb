module Spree
  ProductsController.class_eval do

    before_action :load_taxonomies, only: :show

    def show
      if @product && @product.live?
        @variants = Spree::Variant.active.includes([:option_values, :images]).where(product_id: @product.id)
        @product_properties = Spree::ProductProperty.includes(:property).where(product_id: @product.id)
        @taxon = params[:taxon_id].present? ? Spree::Taxon.find(params[:taxon_id]) : @product.taxons.first
        respond_with(@product)
      else
        redirect_to root_url, :error => Spree.t(:error, scope: [:active_sale, :event, :flash])
      end
    end

    private
      def load_taxonomies
        @taxonomies = Spree::Taxonomy.includes(root: :children)
      end
  end
end
