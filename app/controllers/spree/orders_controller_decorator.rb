module Spree
  OrdersController.class_eval do
    before_action :check_active_products_in_order
    
  end
end
