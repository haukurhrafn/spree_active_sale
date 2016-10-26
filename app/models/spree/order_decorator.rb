Spree::Order.class_eval do

  def delete_inactive_items
    self.line_items.each do |line_item|
      remove_line_item(line_item) unless line_item.live?
    end
  end

  def remove_line_item(line_item)
    Spree::OrderContents.new(self).remove(line_item.variant, line_item.quantity)
  end

end
