require "bodega/engine"
require 'configurator'

module Bodega
  extend Configurator
  option :customer_method, :current_user
  option :product_name, 'product'
  option :payment_method, :plinq
end
