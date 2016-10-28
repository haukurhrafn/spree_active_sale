module Spree
  class SaleProperty < Spree::Base
    belongs_to :active_sale_event
    belongs_to :property

    validates :active_sale_event, :property, presence: true
    validates :value, length: { maximum: 255 }
    default_scope { order(:position) }

    delegate :name, to: :property, allow_nil: true

    def property_name=(name)
      unless name.blank?
        unless property = Property.find_by_name(name)
          property = Property.create!(name: name, presentation: name)
        end
        self.property = property
      end
    end
  end
end
