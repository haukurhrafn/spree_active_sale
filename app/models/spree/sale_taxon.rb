module Spree
  class SaleTaxon < Spree::Base
    #TODO: validation for presence
    belongs_to :active_sale_event, class_name: 'Spree::ActiveSaleEvent'
    belongs_to :taxon, class_name: 'Spree::Taxon'

    validates :taxon, presence: true
  end
end
