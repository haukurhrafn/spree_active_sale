# coding: UTF-8
require 'spec_helper'

describe Spree::CheckoutController, type: :controller do

  stub_authorization!
  it { is_expected.to use_before_action(:check_active_products_in_order) }

end
