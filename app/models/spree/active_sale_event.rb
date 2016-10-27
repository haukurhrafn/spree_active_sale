# ActiveSaleEvent
# Events represent an entity/ schedule for active sale in a flash sale/ daily deal.
# There can be many events/ schedules for one sale.
#
module Spree
  class ActiveSaleEvent < Spree::Base

    has_many :sale_images, -> { order(:position) }, as: :viewable, dependent: :destroy
    has_many :sale_products, -> { order(:position) }, dependent: :destroy
    has_many :products, through: :sale_products
    has_many :sale_taxons, -> { order(:position) }, dependent: :destroy
    has_many :taxons,  -> { order(:position) }, through: :sale_taxons
    has_many :sale_properties, dependent: :destroy
    has_many :properties, through: :sale_properties
    belongs_to :active_sale
#TODO: validate active_save intead of id
    validates :name, :start_date, :end_date, :active_sale, presence: true
    validate  :validate_start_and_end_date, if: :invalid_dates?
    validate  :validate_with_live_event

    class << self
      # Spree::ActiveSaleEvent.is_live? method
      # should only/ always represents live and active events and not just live events.
      def is_live? object
        object_class_name = object.class.name
        return object.live_and_active? if object_class_name == self.name
        %w(Spree::Product Spree::Variant Spree::Taxon).include?(object_class_name) ? object.live? : false
      end

      def paginate(options = {})
        options = prepare_pagination(options)
        self.page(options[:page]).per(options[:per_page])
      end

      private

        def prepare_pagination(options)
          per_page = options[:per_page].to_i
          options[:per_page] = per_page > 0 ? per_page : Spree::ActiveSaleConfig[:active_sale_events_per_page]
          page = options[:page].to_i
          options[:page] = page > 0 ? page : 1
          options
        end
    end

#TODO: Remove self
    # override the delete method to set deleted_at value
    # instead of actually deleting the event.
    def delete
      update_column(:deleted_at, object_zone_time)
    end

    # return product's or sale's with prefix permalink
    def permalink
      single_product_sale? && product.present? ? product : active_sale
    end

    def product
      products.first
    end

    def live?(moment=object_zone_time)
      (start_date <= moment && end_date >= moment) || is_permanent? if start_and_dates_available?
    end

    def upcoming?(moment=object_zone_time)
      (start_date >= moment && end_date > start_date) if start_and_dates_available?
    end

    def past?(moment=object_zone_time)
      (start_date < moment && end_date > start_date && end_date < moment) if start_and_dates_available?
    end

    def live_and_active?(moment=nil)
      live?(moment) && is_active?
    end

    def start_and_dates_available?
      start_date && end_date
    end

    def invalid_dates?
      start_and_dates_available? && (start_date >= end_date)
    end

    def time_left
      end_date - object_zone_time
    end

    private

#TODO: refactor validate_start_and_end_date move condition to validation
      # check if there is start and end dates are correct
      def validate_start_and_end_date
        errors.add(:start_date, Spree.t('active_sale.event.validation.errors.invalid_dates'))
      end

      #TODO: refactor validate_with_live_event, remove self, rearrange condition, sql
      # check if there is no another event is currently live and active
      def validate_with_live_event
        if id.nil? && live? && !active_sale.active_sale_events.select{ |ase| ase.live? }.blank?
          errors.add(:another_event, Spree.t('active_sale.event.validation.errors.live_event'))
        elsif live? && !active_sale.active_sale_events.where.not(id: id).select{ |ase| ase.live? }.blank?
          errors.add(:another_event, Spree.t('active_sale.event.validation.errors.live_event'))
        end
      end

      def object_zone_time
        Time.current #TODO: Time.current
      end
  end
end

require_dependency 'spree/active_sale_event/scopes'
