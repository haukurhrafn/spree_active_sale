module Spree
  ProductsController.class_eval do
    HTTP_REFERER_REGEXP = /^https?:\/\/[^\/]+\/t\/([a-z0-9\-\/]+)$/ unless defined? HTTP_REFERER_REGEXP

    before_action :load_taxonomies, only: :show

    private
      def load_taxonomies
        @taxonomies = Spree::Taxonomy.includes(root: :children)
      end
  end
end
