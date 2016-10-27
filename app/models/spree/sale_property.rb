module Spree
  class SaleProperty < Spree::Base
    #TODO: validation fix add validation for belongs_to
    belongs_to :active_sale_event
    belongs_to :property

    validates :active_sale_event, :property, presence: true
    validates :value, length: { maximum: 255 }
    default_scope { order(:position) }

    delegate :name, to: :property, allow_nil: true

    #TODO:delegate
    # def property_name
    #   property.name if property
    # end

    def property_name=(name)
      unless name.blank?
        unless property = Property.find_by_name(name)
          #TODO: use create!
          property = Property.create!(name: name, presentation: name)
        end
        self.property = property
      end
    end
  end
end
